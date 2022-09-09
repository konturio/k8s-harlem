Secret has been created manually

```bash
docker run -e PASSWORD="<your password>" -it golang:1.17 bash -c 'go install github.com/bitnami/bcrypt-cli@v1.0.2 2> /dev/null && echo -n $PASSWORD | bcrypt-cli'

kubectl create secret generic cluster-user-auth \
  --namespace flux-system \
  --from-literal=username=wego-admin \
  --from-literal=password='$2a...'

```