cd ~

wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
        /bin/bash ~/miniconda.sh -b -p /opt/conda

export PATH="/opt/conda/bin:$PATH"
conda init
source ~/.bashrc
conda create -n bk python=3.11
        