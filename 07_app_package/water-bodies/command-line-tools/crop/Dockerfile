FROM mambaorg/micromamba

USER root

ENV USERNAME=mambauser 

ENV PATH=/srv/conda/envs/env_crop/bin:$PATH

RUN apt-get update -y \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl sudo git gcc build-essential

RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

RUN mkdir -p /srv/conda && chown -R mambauser:1000 /srv/conda/

RUN mkdir -p /workspaces/vscode-binder/command-line-tools/crop

RUN chown -R 1000:1000 /workspaces/vscode-binder/command-line-tools/crop

USER mambauser

RUN micromamba create -r /srv/conda -n env_crop -c conda-forge gdal click pystac  



ADD app.py /workspaces/vscode-binder/command-line-tools/crop/app.py

WORKDIR /home/mambauser
