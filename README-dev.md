# Developer Notes for Workshop Preparation

Each participant will have their own VM running in CREODIAS. Currently there is a single VM accessible through the public IP `185.52.195.215` and can be accessed by ssh...
```
ssh eouser@185.52.195.215 (password foss4gworkshop)
```
...the intention being to use this VM as a representative environment against which to prepare the notebooks.<br>
Each participant VM will be the same but with a different public IP.

The git repo for the workshop is here - https://github.com/EOEPCA/workshop
* deployment files are under directory `VM/`
* notebooks are under directory `workshop/notebooks/`

You can clone the git repo and run the notebooks locally...
```
git clone git@github.com:EOEPCA/workshop
cd workshop
./run.sh
```
...which runs Jupyter via docker-compose and exposes on your localhost port `8888`.

You can use the public endpoints of the exposed (ingress) services - e.g. https://resource-catalogue.185-52-195-215.nip.io/. All ingress use the public IP address of the VM with `.nip.io` notation.

You can also ssh to the VM and run Jupyter there - in which case it is exposed at http://185.52.195.215:8888/. Only one person at a time can do this - unless we do something to offset ports for different instances.

The `run.sh` script maps the local `kubeconfig` file into the running Jupyter container - thus providing `kubectl` access to the cluster where this is needed for direct interaction. This only works when `run.sh` is invoked directly on the VM (which has local access to the cluster) - i.e. `kubectl` access won't work if you're running on your own machine.
