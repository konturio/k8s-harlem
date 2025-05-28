tigera-operator & calico
============

Calico is deployed using the tigera-operator via FluxCD. It's installed through a HelmRelease in the tigera-operator namespace, using the tigera-operator Helm chart version 3.29.2 from the projectcalico HelmRepository.

A custom FelixConfiguration is applied (```core-apps/base/calico/felix_configuration.yaml```).<br> IP-in-IP tunneling is enabled. Specific inbound and outbound failsafe ports are explicitly allowed to ensure node and control-plane communication (e.g., ssh, postgres, k8s API, DNS, etc.). 
