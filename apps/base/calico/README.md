Calico Network Policies
=======================
Calico network policy not only protects workloads, but also hosts. Here we create a Calico network policies to restrict traffic to/from hosts https://projectcalico.docs.tigera.io/security/hosts

## Hosts and workloads
In the context of Calico configuration, a `workload` is a virtualized compute instance, like a VM or container. A `host` is the computer that runs the hypervisor (for VMs), or container runtime (for containers). We say it “hosts” the workloads as guests.

## Host endpoints
Each host has one or more network interfaces that it uses to communicate externally. You can use Calico network policy to secure these interfaces (called host endpoints). Calico host endpoints can have labels, and they work the same as labels on workload endpoints. The network policy rules can apply to both workload and host endpoints using label selectors.

# Failsafe rules
It is easy to inadvertently cut all host connectivity because of non-existent or misconfigured network policy. To avoid this, Calico provides failsafe rules with default/configurable ports that are open on all host endpoints.

>If a host endpoint is created and network policy is not in place, the Calico default is to deny traffic to/from that endpoint (except for traffic allowed by `failsafe` rules). For a named host endpoint (i.e. a host endpoint representing a specific interface), Calico blocks traffic only to/from the interface specified in the host endpoint. Traffic to/from other interfaces is ignored.
>That is why important create policy first and then create host endpoints

## Useful commands

### Get Calico nodes
```bash
$ calicoctl --allow-version-mismatch get nodes -o wide
NAME                        ASN       IPV4                IPV6
master01.k8s-02.kontur.io   (64512)   10.217.128.201/32
master02.k8s-02.kontur.io   (64512)   10.217.128.202/32
master03.k8s-02.kontur.io   (64512)   10.217.128.203/32
node01.k8s-02.kontur.io     (64512)   10.217.128.101/32
node02.k8s-02.kontur.io     (64512)   10.217.128.102/32
node03.k8s-02.kontur.io     (64512)   10.217.128.103/32
```

### Get HostEndpoint
```bash
$ calicoctl --allow-version-mismatch get heps -owide
NAME                    NODE     INTERFACE   IPS   PROFILES
master-all-interfaces   cp       *
master-eth0             cp       eth0
worker-all-interfaces   worker   *
worker-eth0             worker   eth0
```

### Get GlobalNetworkPolicy
```bash
$ calicoctl --allow-version-mismatch get gnp -o wide
NAME                             ORDER   SELECTOR
allow-cluster-internal-ingress   10      has(host-endpoint)
allow-nodeport                   10      has(host-endpoint)
allow-outbound-external          10      has(host-endpoint)
drop-other-ingress               20      has(host-endpoint)
ingress-k8s-workers              50      role == 'worker-all-int'
k8s-master                       50      role == 'master-all-int'
```
