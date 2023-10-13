# EOEPCA Workshop - BiDS 2023

November 6th 2023

Workshop to demonstrate the capabilities of the EOEPCA building blocks.

## Agenda

* Introduction and Setup [10 mins]
* Data Discovery, Search and Transactions [15 mins]
* Services for Data Access and Visualisation [15 mins]
* Processing Application Deploy, Execution and Results Exploitation [40 mins]
* Visualise results in User Workspace [10 mins]

## Participant Pre-requisites

The workshop is conducted through a combination of:
* Jupyter Notebooks
* Presentation Slides
* Web Applications

The Jupyter Notebooks are designed to be run locally be each participant. The notebooks steps interface with the services of our EOEPCA Demo Cluster (demo.eoepca.org).

There are two approaches to invoke the JupyterLab environment to exploit the notebooks...
* **Pre-packaged Container Image**<br>
  Via our pre-prepared container image that includes JupyterLab and all necessary files
* **Native JupyterLab**<br>
  Via JupyterLab running natively in your local environment

All required files are available in the [Workshop git repository](https://github.com/EOEPCA/workshop) at https://github.com/EOEPCA/workshop.

### Use Pre-packaged Container Image (Recommended)

This approach relies upon a local installation of [Docker Engine](https://docs.docker.com/engine/).

Once docker is installed then you can pull the workshop container image...

```
docker pull eoepca/workshop
```

**It is strongly advised to perform this step prior to the workshop - due to the size of the download.**

The easiest way to use the workshop container image is via the run script in the repo (assumes bash)...

```
git clone https://github.com/EOEPCA/workshop
cd workshop
./run.sh
```

This script maps your local copy of the notebooks (cloned from the repo) into the running container image. This ensures that you are using the latest versions of the notebooks from the repo, rather than the ones included in the container image - and so mitigates the possibility of last minute changes to the notebooks being missing from your copy of the container image. In addition, it allows your notebook executions to be persisted locally outside of the container.

The script equates to the following `docker run` command...

```
docker run --rm --name jupyterlab \
  --user root \
  -p 8888:8888 \
  -v ${PWD}/workshop:/home/${NB_USER}/work \
  -e NB_USER="${NB_USER}" \
  -e NB_UID="${NB_UID}" \
  -e NB_GID="${NB_GID}" \
  -e CHOWN_HOME="yes" \
  -e JUPYTER_ENABLE_LAB="yes" \
  eoepca/workshop \
  start-notebook.sh --NotebookApp.token=\'\'
```

...where environment variables are set for the username (`NB_USER`), user ID (`NB_UID`) and group (`NB_GID`) - in order to map your local user permissions into the running container for file ownerships.

### Use Native JupyterLab

_Note that this option is less well tested by ourselves, since we rely upon the container image._

This approach assumes you have python3 installed in your local platform.

Clone the repo to your local environment...

```
git clone https://github.com/EOEPCA/workshop
cd workshop
```

zzz
