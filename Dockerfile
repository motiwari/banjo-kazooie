FROM ubuntu:20.04 AS build
ENV DEBIAN_FRONTEND=noninteractive

# (for debug purposes)
RUN echo "System arch: $(uname -a)\nDPKG arch: $(dpkg --print-architecture)"

# Install package dependencies
COPY packages.txt ./
RUN apt-get update && apt-get install -y $(cat packages.txt) && rm packages.txt

# Install Rust/Cargo
# NOTE: We replace /proc/self/exe with /bin/sh in the script to avoid issues with Docker
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sed 's#/proc/self/exe#\/bin\/sh#g' | CARGO_HOME=/opt/cargo sh -s -- -y
ENV PATH=/opt/cargo/bin:$PATH

# Install Python dependencies
COPY requirements.txt ./
COPY tools/n64splat/requirements.txt ./tools/n64splat/requirements.txt


# Set up Python3.11 instead of 3.8
RUN cd ~

RUN curl -fsSL "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" -o /tmp/miniconda.sh 
RUN /bin/bash /tmp/miniconda.sh -b -p /opt/conda
RUN rm /tmp/miniconda.sh

# RUN ls /opt/conda/bin
ENV PATH="/opt/conda/bin:${PATH}"

RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
RUN conda init

RUN conda create -n bk python=3.11

RUN conda run -n bk python3 --version

RUN conda run -n bk python3 -m pip install -r requirements.txt

# For entrypoint
RUN echo "conda activate bk" >> ~/.bashrc

WORKDIR /banjo
ENTRYPOINT ["/bin/bash", "-c"]
