cert-manager
============

According to https://cert-manager.io/docs/installation/helm/#3-install-customresourcedefinitions we need install CRDs first.

In our Flux we have "pipeline" `core-aps`-->`apps` (`apps` depends on `core-apps`), so putting CRDs manifests under `core-apps`,
rest of installation is inder `apps`.
