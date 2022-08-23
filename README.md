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
- [FAQ](#faq)
  * [How can I safely move resources from one dir to another?](#How can I safely move resources from one dir to another?)
  * [Useful commands](Useful commands)

This repository stores Kubernetes manifests, which are synced and applied to the clusters every N minutes, via Flux - https://fluxcd.io/

Flux is a tool for keeping Kubernetes clusters in sync with sources of configuration (like Git repositories), and automating updates to configuration when there is new code to deploy.

## Core Concepts
### GitOps
GitOps is a way of managing your infrastructure and applications so that whole system is described declaratively and version controlled, and having an automated process that ensures that the deployed environment matches the state specified in a repository.

### Sources
A Source https://fluxcd.io/docs/components/source/ defines the origin of a repository containing the desired state of the system and the requirements to obtain it. Sources produce an artifact that is consumed by other Flux components to perform actions, like applying the contents of the artifact on the cluster. The origin of the source is checked for changes on a defined interval, if there is a newer version available that matches the criteria, a new artifact is produced.
Examples of sources are:
- `GitRepository` - usually plain k8s manifests. Consumed by `Kustomize` controller.
- `HelmRepository` - usually Helm HTTP/S repository, which defines a Source to produce an Artifact for a Helm repository index YAML (`index.yaml`). Consumed by `Helm` controller.

### Reconciliation
Reconciliation refers to ensuring that a given state (e.g. application running in the cluster, infrastructure) matches a desired state declaratively defined in Git repository.
- `HelmRelease` reconciliation: ensures the state of the Helm release matches what is defined in the resource, performs a release if this is not the case (including revision changes of a HelmChart resource).
- `Kustomization` reconciliation: ensures the state of the application deployed on a cluster matches the resources defined in a Git repository.

### Kustomization
The Kustomization custom resource represents a local set of Kubernetes resources (e.g. kustomize overlay) that Flux is supposed to reconcile in the cluster. In Flux there are two Kustomization types. `kustomization.kustomize.toolkit.fluxcd.io` is a Kubernetes custom resource while `kustomization.kustomize.config.k8s.io` is the type used to configure a Kustomize overlay. The `kustomization.kustomize.toolkit.fluxcd.io` object refers to a `kustomization.yaml` file path inside a Git repository.

## Repository structure
- **apps** dir contains Helm releases and k8s manifests with a custom configuration per cluster
- **core-apps** dir contains Helm releases and k8s manifests for common tools which should be provisioned first. For example `vmcluster` from `apps` has dependoncy of `local-path-provisioner` from `core-apps`
- **clusters** dir contains the Flux configuration per cluster

Each cluster state is defined in a dedicated dir e.g. `clusters/production` where the specific apps and infrastructure overlays are referenced.

>The separation between apps and infrastructure makes it possible to define the order in which a cluster is reconciled, e.g. first the cluster addons and other >Kubernetes controllers, then the applications.

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
- **core-apps/sources/** dir contains HelmRepository source definitions
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
│   └── core-apps.yaml
└── k8s-02
```

## Installation
Flux itself is bootstrapped via [terraform](https://gitlab.com/kontur-private/operations/terraform/-/tree/main/kubernetes/flux).

## Notifications
The Flux controllers emit Kubernetes events whenever a resource status changes. We use the `notification-controller` to forward these [events](https://fluxcd.io/docs/guides/notifications/) to Slack `#flux` channel.

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
