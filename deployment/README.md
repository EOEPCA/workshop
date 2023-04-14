# Deploy EOEPCA

The EOEPCA system is deployed to a target Kubernetes cluster with a GitOps approach using Flux Continuous Delivery (https://fluxcd.io/).

## Install Flux

Install the Flux CLI following the [Flux installation instructions](https://fluxcd.io/flux/installation/#install-the-flux-cli)

## Flux prerequisites

The flux pre-requisites can be checked...

```
flux check --pre
```

## GitHub credentials

GitHub is assumed for these instructions, as used by the [deployment script](./deploy-to-cluster), but other git repos can be used - as described here (https://toolkit.fluxcd.io/guides/installation/#generic-git-server).

A Personal Access Token (PAT) will be required by Flux, these can be created as described here (https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token).

When creating the token, all 'repo' scopes should be selected.

## Prepare the deployment TARGET

The repository structure is separated in to the following areas:
- apps: containing the core eoepca applications to deploy
- clusters: containing the configuration and (FluxCD) deployments for each cluster
- infrastructure: containing the pre-requisite infrastructure components and configuration required by the apps (e.g. CRDs, NGINX, certificates)

The order of deployment for `./clusters`, `./infrastructure` and `./apps` is controlled by the FluxCD configuration in `./clusters/<target system>`, however the general expected order is:
1. bootstrap flux for the corresponding cluster in `./clusters`
2. deploy system-wide configuration from `./clusters/<target system>`
3. deploy pre-requisite infrastructure from `./infrastructure`
4. deploy eoepca applications from `./apps`

This deployment order is controlled using [Kustomizations](https://fluxcd.io/flux/components/kustomize/kustomization/), an example for which is demonstrated with the Mundi pipeline `./clusters/mundi/pipeline.yaml`

In order to deploy for a different system the following should be performed:
- Create and bootstrap a new directory `./clusters/<target system>` should be created as a copy from the Mundi deployment, with:
- its configuration file `./clusters/<target system>/configuration.yaml` modified to reflect the values for the new cluster (e.g. publicIp)
- any paths in `./clusters/<target system>/pipeline.yaml` updated as neccessary to point to system-specific resource definitions.

## Initialise the EOEPCA Deployment in Flux

The [deployment script](./deploy-to-cluster) bootstraps Flux in to the currently active Kubernetes cluster. Run `./deploy-to-cluster -h` for a full breakdown of the usage of this script.

NOTE. For deployment of additional clusters it is essential to make a copy of the `clusters/<target system>` directory, to ensure that the cluster deployment configuration that flux maintains in GitHub is kept independent for each cluster.

## (Re)generate secrets

After deployment of the sealed secrets controller, sealed secrets must be (re)generated using the certificate associated with the controller.
The resources for these secrets are stored in `./infrastructure/configs/<target system>`. The mundi deployment contains helper scripts which can be executed to generate the resources for these secrets. Once (re)generated, these must be committed to GIT and deployed via flux for resources depending on the secrets to deploy successfully.

See (https://github.com/bitnami-labs/sealed-secrets) for more information on sealed secrets.

# GitOps Synchronisation

The flux deployment specification is expressed through `GitRepository` and `HelmRelease` resources.

Flux will monitor the charts referenced in the Helm Releases, and reconcile the state of the cluster in accordance with any changes to these components.

It should be noted that, when using a GitRepository as source, the referenced HelmRelease must increment their chart version number in order for flux to recognize the update.

# Undeploy Flux

To uninstall the Flux components from the cluster, see (https://fluxcd.io/flux/installation/#uninstall).
