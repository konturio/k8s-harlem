Longhorn
============

1. Longhorn Deployment
Longhorn is deployed in core-apps using a Helm chart. The configurations and manifests can be found in the following repository: https://github.com/konturio/k8s-harlem/tree/main/core-apps/base/longhorn  
The variables used for the deployment are located in the release.yaml file in the values section.

2. Storage Classes
The system is configured with the following storage classes:  
longhorn-single (default StorageClass): single replica.  
longhorn-ha: two replicas by default.

3. Deploying an Application Using Longhorn Storage
To deploy an application using Longhorn storage, modify or create a PersistentVolumeClaim (PVC). Here is an example YAML configuration for the PVC:

```yaml apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: example-pvc
  namespace: example-namespace
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: longhorn-single # or longhorn-ha if needed
```