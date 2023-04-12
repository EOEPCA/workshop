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

A Personal Access Token (PAT) will be required by Flux, these can be created as described here (https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token).

When creating the token, all 'repo' scopes should be selected.

### Prepare the deployment TARGET

The repository structure is separated in to the following areas:
- apps: containing the core eoepca applications to deploy
- clusters: containing the (FluxCD) deployments for each cluster
- configuration: containing cluster-wide configuration (e.g. IP addresses, domain names)
- infrastructure: containing the pre-requisite infrastructure components and configuration required by the apps (e.g. CRDs, NGINX, certificates)

The order of deployment for `./configuration`, `./infrastructure` and `./apps` is controlled by the FluxCD configuration in `./clusters/<target system>`, however the general expected order is:
1. bootstrap flux for the corresponding cluster in `./clusters`
2. deploy system-wide configuration from `./configuration`
3. deploy pre-requisite infrastructure from `./infrastructure`
4. deploy eoepca applications from `./apps`

This deployment order is controlled using [Kustomizations](https://fluxcd.io/flux/components/kustomize/kustomization/), an example for which is demonstrated with the Mundi pipeline `./clusters/mundi/pipeline.yaml`

In order to deploy for a different system, at a mimimum:
- a new set of configuration files should be created in `./configuration/<target system>`, with configuration values set according to the target system (e.g. publicIp)
- a new directory `./clusters/<target system>` should be created, with its own pipeline file configured to use the configuration from `./configuration/<target system>`

### Initialise the EOEPCA Deployment in Flux

The [deployment script](./deploy-to-cluster) bootstraps Flux in to the currently active Kubernetes cluster. Run `./deploy-to-cluster -h` for a full breakdown of the usage of this script.

NOTE. For deployment of additional clusters it is essential to make a copy of the `clusters/<target system>` directory, to ensure that the cluster deployment configuration that flux maintains in GitHub is kept independent for each cluster.

## GitOps Synchronisation

The flux deployment specification is expressed through `GitRepository` and `HelmRelease` resources.

Flux will monitor the charts referenced in the Helm Releases, and reconcile the state of the cluster in accordance with any changes to these components.

It should be noted that, when using a GitRepository as source, the referenced HelmRelease must increment their chart version number in order for flux to recognize the update.

## Undeploy Flux

To uninstall the Flux components from the cluster, see (https://fluxcd.io/flux/installation/#uninstall).
