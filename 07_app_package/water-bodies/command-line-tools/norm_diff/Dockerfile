FROM docker.io/mambaorg/micromamba:latest

USER root

ENV USERNAME=mambauser 

ENV PATH=/srv/conda/envs/env_norm_diff/bin:$PATH

RUN apt-get update -y \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl sudo git gcc build-essential

RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

RUN mkdir -p /srv/conda && chown -R mambauser:1000 /srv/conda/

RUN mkdir -p /workspaces/command-line-tools/norm_diff

RUN chown -R 1000:1000 /workspaces/command-line-tools/norm_diff

USER mambauser

RUN micromamba create -r /srv/conda -n env_norm_diff -c conda-forge gdal click   

ADD water-bodies/command-line-tools/norm_diff/app.py /workspaces/command-line-tools/norm_diff/app.py

WORKDIR /home/mambauser
