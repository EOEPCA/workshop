# Workshop

Workshop explaining eoepca deployment and component features

For the workshop, the EOEPCA system is deployed to a target Kubernetes cluster with a GitOps approach using Flux Continuous Delivery (https://fluxcd.io/).

## Deploy EOEPCA

### Install Flux

Install the Flux CLI following the [Flux installation instructions](https://fluxcd.io/flux/installation/#install-the-flux-cli)

### Flux prerequisites

The flux pre-requisites can be checked...

```
flux check --pre
```

### GitHub credentials

GitHub is assumed for these instructions, as used by the [deployment script](./deploy-to-cluster), but other git repos can be used - as described here (https://toolkit.fluxcd.io/guides/installation/#generic-git-server).

The following environment variables must be set when initialising Flux in the following step...

```
export GITHUB_USER=<your-username>
export GITHUB_TOKEN=<your-token>
```

GITHUB_TOKEN is a Personal Access Token - as described here (https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token).

When creating the token, all 'repo' scopes should be selected.

### Prepare the deployment TARGET

The deplyoments for each system are maitained under the paths `./clusters/<target system>`. Before deployment, the confiuration must be tailored to your deployment environment. In particular the Public IP of the target cluster must be applied within the configuration - achieved by searching for the terms `185.52.193.87` and `185.52.193.87.nip.io` in the configuration (all files under clusters/develop) and adjusting according to your environment.

Rather than edit `<target system>` directly, you may consider making a copy of the directory to represent your cluster.

### Initialise the EOEPCA Deployment in Flux

The [deployment script](./deploy-to-cluster) bootstraps Flux in to the currently active Kubernetes cluster. Run `./deploy-to-cluster -h` for a full breakdown of the usage of this script.

NOTE. For deployment of additional clusters it is essential to make a copy of the `clusters/<target system>` directory, to ensure that the cluster deployment configuration that flux maintains in GitHub is kept independent for each cluster.

## GitOps Synchronisation

The flux deployment specification in `clusters/<target system>` is expressed through `GitRepository` and `HelmRelease` resources.

Flux will monitor the charts referenced in the Helm Releases, and reconcile the state of the cluster in accordance with any changes to these components.

It should be noted that, when using a GitRepository as source, the referenced HelmRelease must increment their chart version number in order for flux to recognize the update.

## Undeploy Flux

To uninstall the Flux components from the cluster, see (https://fluxcd.io/flux/installation/#uninstall).
