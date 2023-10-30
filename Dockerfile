FROM mcr.microsoft.com/devcontainers/python:1-3.9-bullseye

SHELL ["/bin/bash", "-c"]

USER root

RUN apt-get update \
  && apt-get -y install gcc

RUN mkdir /app \
  && chown -R vscode:vscode /app

USER vscode
WORKDIR /app

COPY --chown=vscode functions .
COPY --chown=vscode workshop/requirements.txt workshop/requirements.txt

RUN source functions \
  && export PYTHON=`which python` \
  && createVenv

COPY --chown=vscode run-jupyter.sh .

COPY --chown=vscode workshop workshop

ENTRYPOINT [ "bash" ]
