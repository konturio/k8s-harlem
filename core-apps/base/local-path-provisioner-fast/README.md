local-path-provisioner
============

The default StorageClass is local-path-fast (rancher.io/local-path-fast). It uses the Delete reclaim policy and WaitForFirstConsumer binding mode.

Disks on each node are aggregated using LVM and mounted under /, so all available space is shared. When a PVC is provisioned via this StorageClass, the data directory is created under /opt/local-path-provisioner on the node where the pod is scheduled.
