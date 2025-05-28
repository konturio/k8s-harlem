Flux GitOps repository
======================

- [Core Concepts](#core-concepts)
  * [GitOps](#gitops)
  * [Sources](#sources)
  * [Reconciliation](#reconciliation)
  * [Kustomization](#kustomization)
- [Repository Structure](#repository-structure)
- [Installation](#installation)
- [Notifications](#notifications)
- [Image automation](#image-reflector-and-automation-controllers)
- [FAQ](#faq)
  * [How can I safely move resources from one dir to another?](#how-can-i-safely-move-resources-from-one-dir-to-another)
  * [Useful commands](#useful-commands)

This repository stores Kubernetes manifests, which are synced and applied to the clusters every N minutes via Flux - https://fluxcd.io/

Flux is a tool for keeping Kubernetes clusters in sync with sources of configuration (like Git repositories) and automating updates to the configuration when new code is deployed.

## Core Concepts
### GitOps
GitOps is a way of managing your infrastructure and applications so that the whole system is described declaratively and version controlled and has an automated process that ensures that the deployed environment matches the state specified in a repository.

### Sources
A Source https://fluxcd.io/docs/components/source/ defines the origin of a repository containing the desired state of the system and the requirements to obtain it. Sources produce an artifact consumed by other Flux components to perform actions, like applying the artifact's contents on the cluster. The origin of the source is checked for changes on a defined interval, if there is a newer version available that matches the criteria, a new artifact is produced.
Examples of sources are:
- `GitRepository` - usually plain k8s manifests. Consumed by `Kustomize` controller.
- `HelmRepository` - usually Helm HTTP/S repository, which defines a Source to produce an Artifact for a Helm repository index YAML (`index.yaml`). Consumed by `Helm` controller.

### Reconciliation
Reconciliation refers to ensuring that a given state (e.g., the application running in the cluster, infrastructure) matches the desired state declaratively defined in Git repository.
- `HelmRelease` reconciliation ensures the state of the Helm release matches what is defined in the resource, performs a release if this is not the case (including revision changes of a HelmChart resource).
- `Kustomization` reconciliation ensures the state of the application deployed on a cluster matches the resources defined in a Git repository.

### Kustomization
The Kustomization custom resource represents a local set of Kubernetes resources (e.g. kustomize overlay) that Flux is supposed to reconcile in the cluster. In Flux there are two Kustomization types. `kustomization.kustomize.toolkit.fluxcd.io` is a Kubernetes custom resource, while `kustomization.kustomize.config.k8s.io` is the type used to configure a Kustomize overlay. The `kustomization.kustomize.toolkit.fluxcd.io` object refers to a `kustomization.yaml` file path inside a Git repository.

## Repository structure
- **apps** dir contains Helm releases and k8s manifests with a custom configuration per cluster
- **core-apps** dir contains Helm releases and k8s manifests for common tools, which should be provisioned first. For example, `vmcluster` from `apps` has a dependency on `local-path-provisioner` from `core-apps`
- **clusters** dir contains the Flux configuration per cluster

Each cluster state is defined in a dedicated dir e.g. `clusters/production` where the specific apps and infrastructure overlays are referenced.

>The separation between apps and infrastructure makes it possible to define the order in which a cluster is reconciled, e.g. first the cluster add-ons and other >Kubernetes controllers, then the applications.

```
├── apps
│   ├── base
│   └── clusters
├── core-apps
│   ├── base
│   ├── clusters
│   └── sources
└── clusters
    ├── k8s-01
    └── k8s-02
```
The `apps` configuration is structured into:
- **apps/base/** dir contains common k8s manifests and Helm release definitions
- **apps/clusters/** dir contains custom apps patches from `base` folder for particular cluster
```
.
.
├── base
│   ├── postgres-exporter
│   │   ├── kustomization.yaml
│   │   ├── london
│   │   ├── milan
│   │   └── paris
│   └── vmcluster
│       ├── kustomization.yaml
│       └── vmcluster-crd.yaml
└── clusters
    ├── k8s-01
    │   ├── kustomization.yaml
    │   └── vmcluster
    └── k8s-02
        ├── kustomization.yaml
        └── vmcluster
```

The `core-apps` configuration is structured into:
- **core-apps/base/** dir contains common k8s manifests and Helm release definitions
- **core-apps/clusters/** dir contains custom apps patches from `base` folder for particular cluster and namespace definitions
- **core-apps/sources/** dir contains known Source's for Source Controller, e.g., HelmRepository, GitRepository, etc.
```
.
.
├── base
│   ├── kube-prometheus-operator
│   ├── local-path-provisioner
│   └── victoriametrics-operator
├── clusters
│   ├── k8s-01
│   └── k8s-02
└── sources
    ├── kustomization.yaml
    ├── prometheus-community.yaml
    └── victoriametrics.yaml
```

The `clusters` configuration is structured into:
- **clusters/k8s-[01-02]/flux-system/** dir contains Flux components manifests
- **clusters/k8s-[01-02]/apps.yaml/** Flux CRD Kustomization definition for `apps` folder
- **clusters/k8s-[01-02]/core-apps.yaml/** Flux CRD Kustomization definition for `core-apps` folder
```
./clusters/
├── k8s-01
│   ├── flux-system
│   ├── apps.yaml
│   ├── core-apps.yaml
│   └── kontur-platform.yaml
└── k8s-02
```

## Installation
Flux itself is bootstrapped via [flux bootstrap for GitHub](https://fluxcd.io/flux/installation/bootstrap/github/).

## Notifications
The Flux controllers emit Kubernetes events whenever a resource status changes. We use the `notification-controller` to forward these [events](https://fluxcd.io/docs/guides/notifications/) to Slack `#flux` channel.

## Image reflector and automation controllers
The `image-reflector-controller` and `image-automation-controller` work together to update a Git repository when new container images are available. [(description)](https://fluxcd.io/flux/components/image/)
*not implemented yet

## FAQ
### How can I safely move resources from one dir to another?
- https://fluxcd.io/docs/faq/#how-can-i-safely-move-resources-from-one-dir-to-another

### Useful commands
- https://fluxcd.io/docs/cmd/

```bash
flux get all -A

flux get kustomization --all-namespaces
kubectl get kustomizations -A

flux get sources helm -A
kubectl get helmrepository -A

flux get sources chart -A
kubectl get helmchart -A

flux get helmreleases -A
kubectl get helmreleases -A
helm ls -A
```

### How verify customization?
```bash
kustomize build core-apps/clusters/k8s-02/ | less
```
```bash
kustomize build core-apps/clusters/k8s-02/ | kubectl apply --server-side --dry-run=server -f-
```

## Pre-commit hooks
This repository utilizes pre-commit hooks which are managed by [pre-commit tool][1].

### Installing pre-commit hooks
All of the required tooling can be installed directly or via the setup script:

```bash
./git-hooks/setup-git-hooks.sh
```

### Usage pre-commit hooks
pre-commit hooks will now run on every commit. Every time you clone a project using pre-commit running `pre-commit install` or script above `./git-hooks/setup-git-hooks.sh` should always be the first thing you do.

If you want to manually run all pre-commit hooks on a repository, run `pre-commit run -a`. To run individual hooks use `pre-commit run <hook_id>`

## Links
[1]: https://pre-commit.com/
