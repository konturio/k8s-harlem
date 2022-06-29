Flux GitOps repository
======================

- [Core Concepts](#core-concepts)
  * [GitOps](#gitops)
  * [Sources](#sources)
  * [Reconciliation](#reconciliation)
  * [Kustomization](#kustomization)
- [Repository Structure](#repository-structure)
- [Installation](#installation)

This repository stores Kubernetes manifests, which are synced and applied to the clusters every N minutes, via Flux - https://fluxcd.io/

Flux is a tool for keeping Kubernetes clusters in sync with sources of configuration (like Git repositories), and automating updates to configuration when there is new code to deploy.

## Core Concepts
### GitOps
GitOps is a way of managing your infrastructure and applications so that whole system is described declaratively and version controlled, and having an automated process that ensures that the deployed environment matches the state specified in a repository.

### Sources
A Source defines the origin of a repository containing the desired state of the system and the requirements to obtain it. Sources produce an artifact that is consumed by other Flux components to perform actions, like applying the contents of the artifact on the cluster.

### Reconciliation
Reconciliation refers to ensuring that a given state (e.g. application running in the cluster, infrastructure) matches a desired state declaratively defined in Git repository.
- `HelmRelease` reconciliation: ensures the state of the Helm release matches what is defined in the resource, performs a release if this is not the case (including revision changes of a HelmChart resource).
- `Kustomization` reconciliation: ensures the state of the application deployed on a cluster matches the resources defined in a Git repository or S3 bucket.

### Kustomization
The Kustomization custom resource represents a local set of Kubernetes resources (e.g. kustomize overlay) that Flux is supposed to reconcile in the cluster. In Flux there are two Kustomization types. `kustomization.kustomize.toolkit.fluxcd.io` is a Kubernetes custom resource while `kustomization.kustomize.config.k8s.io` is the type used to configure a Kustomize overlay. The `kustomization.kustomize.toolkit.fluxcd.io` object refers to a `kustomization.yaml` file path inside a Git repository.

## Repository structure
- **apps** dir contains Helm releases and k8s manifests with a custom configuration per cluster
- **infrastructure** dir contains Helm releases and k8s manifests for common infra tools such as NGINX ingress controller
-**clusters** dir contains the Flux configuration per cluster

Each cluster state is defined in a dedicated dir e.g. clusters/production where the specific apps and infrastructure overlays are referenced.

The separation between apps and infrastructure makes it possible to define the order in which a cluster is reconciled, e.g. first the cluster addons and other Kubernetes controllers, then the applications.

```
├── apps
│   ├── base
│   └── clusters
├── infrastructure
│   ├── base
│   └── clusters
└── clusters
    ├── k8s-01
    └── k8s-02
```
The `apps` configuration is structured into:
- **apps/base/** dir contains common k8s manifests, Helm release and HelmRepository source definitions
- **apps/clusters/** dir contains custom apps patches from `base` folder for particular cluster
```
.
├── base
│   ├── atlantis
│   └── podinfo
└── clusters
    ├── k8s-01
    └── k8s-02
```

The `infrastructure` configuration is structured into:
- **infrastructure/base/** dir contains common k8s manifests, Helm release and HelmRepository source definitions
- **infrastructure/clusters/** dir contains custom apps patches from `base` folder for particular cluster
```
.
├── base
│   ├── atlantis
│   └── podinfo
└── clusters
    ├── k8s-01
    └── k8s-02
```

The `clusters` configuration is structured into:
- **clusters/flux-system/** dir contains Flux components manifests
- **clusters/apps.yaml/** Flux CRD Kustomization definition for `apps` folder
- **clusters/infrastructure.yaml/** Flux CRD Kustomization definition for `infrastructure` folder
```
./clusters/
├── k8s-01
│   ├── flux-system
│   ├── apps.yaml
│   └── infrastructure.yaml
└── staging
    ├── flux-system
    ├── apps.yaml
    └── infrastructure.yaml
```
