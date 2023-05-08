FROM jupyter/scipy-notebook:lab-3.0.14

# Kubernetes support files
USER root
RUN apt-get update && \
    apt-get install -y curl && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Use the built-in user
USER ${NB_USER}

# Move to the work dir
WORKDIR ${HOME}/work

# Install the python requirements in an early layer,
# since it shouldn't change that often and takes a while to execute.
COPY --chown=${NB_UID}:${NB_GID} workshop/requirements.txt .
RUN pip install --no-cache-dir -U -r requirements.txt

# Copy across the demo files
COPY --chown=${NB_UID}:${NB_GID} workshop .
