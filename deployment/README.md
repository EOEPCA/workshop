# EOEPCA Deployments

Various deployment configurations of EOEPCA may be stored here for demonstrations in workshops. An approach is taken for the definition of these deployments such that they can re-use and build on a common pattern for deploying the various EOEPCA components, to minimise the configuration required for the standard base resources.

The deployments demonstrate using [Flux Continuous Delivery](https://fluxcd.io/) to monitor and deploy resources directly from this repository.

- [EOEPCA Deployments](#eoepca-deployments)
- [Prerequisites](#prerequisites)
  - [Install Flux](#install-flux)
  - [GitHub Credentials](#github-credentials)
- [Prepare the target deployment cluster](#prepare-the-target-deployment-cluster)
  - [Cluster Configuration](#cluster-configuration)
  - [Cluster Resources](#cluster-resources)
- [Initialise the EOEPCA Deployment in Flux](#initialise-the-eoepca-deployment-in-flux)
- [(Re)generate secrets](#regenerate-secrets)
- [Undeploy Flux](#undeploy-flux)


# Prerequisites

## Install Flux

The EOEPCA system is deployed to a target Kubernetes cluster with a GitOps approach using [Flux Continuous Delivery](https://fluxcd.io/).

Install the Flux CLI following the [Flux installation instructions](https://fluxcd.io/flux/installation/#install-the-flux-cli)

Note: After installation, the flux version and requirments can be checked by executing `flux check --pre`


## GitHub Credentials

GitHub is assumed for these instructions, as used by the [deployment script](./deploy-to-cluster), but other git repos can be used - as described here (https://toolkit.fluxcd.io/guides/installation/#generic-git-server).

A Personal Access Token (PAT) will be required by Flux, these can be created as described here (https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token).

When creating the token, all 'repo' scopes should be selected. Flux will require access to monitor and push changes to this repository granted by this PAT. If you do not have the permissions to create a PAT against this repository to provide this access, or would like to avoid the chance of Flux making any changes, it is recommended to create a fork of the repository with which to deploy against.

# Prepare the target deployment cluster

The deployment structure is separated in to the following areas:
- apps: containing the core EOEPCA applications to deploy
- clusters: containing the configuration and FluxCD resources for each cluster
- infrastructure: containing the pre-requisite infrastructure components and configuration required by the apps (e.g. CRDs, NGINX, certificates)
- pipeline: containing Kustomization resources which control the deployment of `infrastructure` and `apps` resources

The full order of deployment begins with the FluxCD configuration in `./clusters/<target system>`, however the general expected order is:
1. bootstrap flux for the corresponding cluster in `./clusters/<target system>`
2. deploy system-wide configuration from `./clusters/<target system>`
3. deploy the [genericized pipeline](./pipeline/pipeline.yaml)
4. deploy pre-requisite infrastructure from `./infrastructure`
5. deploy eoepca applications from `./apps`

As a quick-start approach, the [Mundi deployment files](./clusters/mundi/) (ignoring the `flux-system` directory) could be coped to `./clusters/<target system>` and the [Cluster Configuration](#cluster-configuration) modified to reflect the intended cluster.

## Cluster Configuration

The resources deployed by Flux in `infrastructure` and `apps` refer to variables, the values for which are substitued in by the pipeline kustomizations in the [genericized pipeline](./pipeline/pipeline.yaml). These values are expected to be provided in a ConfigMap resource named *eoepca-configuration*, deployed to the namespace *eoepca-system*.

For an example of the configuration along with possible values, see the [Mundi deployment configuration](./clusters/mundi/configuration.yaml).

## Cluster Resources

The flux deployment specification is primarily expressed through `GitRepository`, `Kustomization` and `HelmRelease` resources.

Flux will monitor the charts referenced in the Helm Releases, and reconcile the state of the cluster in accordance with any changes to these components.

It should be noted that, when using a GitRepository as source, the referenced HelmRelease must increment their chart version number in order for flux to recognize the update.

The pipeline kustomizations monitor and deploy resources from the `infrastructure` and `apps` directories. Specifically, the pipeline monitors a sub directory `<target system>` in these directories, where the value of `<target system>` is provided by the `clusterName` variable from the [Cluster Configuration](#cluster-configuration). The `kustomization.yaml` file in this `<target system>` directory ultimately controls which resources are deployed for the given target system.

The `infrastructure` and `apps` directories also contain `base` directories containing the common EOEPCA components. These can be referred to by the `<target system>/kustomization.yaml` files, or cluster-specific resources used instead (or as well). This allows for cluster-specific deployments of resources for each system, while maintaining a common approach. Kustomization patches, provided by [Flux](https://fluxcd.io/flux/components/kustomize/kustomization/#patches) or made directly in the [kustomization.yaml file](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/#customizing), can also be used to override values from the `base` resources without having to duplicate their files.

# Initialise the EOEPCA Deployment in Flux

The [deployment script](./deploy-to-cluster) bootstraps Flux in to the currently active Kubernetes cluster. Run `./deploy-to-cluster -h` for a full breakdown of the usage of this script.

NOTE - The path argument should be relative to the repository root. For example: 
```
./deploy-to-cluster -o EOEPCA -r workshop --path ./deployment/clusters/mundi --personal false
```

NOTE - For deployment of additional clusters it is essential to make a copy of the `clusters/<target system>` directory, to ensure that the cluster deployment configuration that flux maintains in GitHub is kept independent for each cluster.

# (Re)generate secrets

In the base deployment, secret values are managed in code and stored securely using [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets). The creation of these secrets depends on the [sealed-secrets-controller](./infrastructure/controllers/base/sealed-secrets.yaml) being deployed to the cluster first. Thus there is a dependency where following resources which require the secrets will fail to deploy on the first deployment, as the secrets will not yet exist.

After deployment of the sealed secrets controller, sealed secrets must be (re)generated using the certificate associated with the controller. The resources for these secrets should then be stored in `./infrastructure/configs/<target system>`, and referred to by the directory's `kustomization.yaml` file.

[Helper scripts](./infrastructure/bin/) have been created which can be executed to generate the resources for these secrets. Once (re)generated, these must be committed to GIT and deployed via flux for resources depending on the secrets to deploy successfully.

# Undeploy Flux

To uninstall the Flux components from the cluster, see (https://fluxcd.io/flux/installation/#uninstall).
