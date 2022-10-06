`grafana-config.yaml` is not presented in this folder because it contains secrets.

```yaml
apiVersion: v1
kind: Secret
metadata:
  labels:
    app.kubernetes.io/component: grafana
    app.kubernetes.io/name: grafana
    app.kubernetes.io/part-of: kube-prometheus
    app.kubernetes.io/version: 8.4.4
  name: grafana-config
  namespace: monitoring
stringData:
  grafana.ini: |
  [server]
  root_url = https://grafana02.kontur.io:443/

  [log]
  level = debug

  [date_formats]
  default_timezone = UTC

  [auth.github]
  enabled = true
  allow_sign_up = true
  client_id = *CENSORED*
  client_secret = *CENSORED*
  scopes = user:email,read:org
  auth_url = https://github.com/login/oauth/authorize
  token_url = https://github.com/login/oauth/access_token
  api_url = https://api.github.com/user
  allowed_organizations = konturio konturlabs konturinc

  [auth.gitlab]
  enabled = true
  allow_sign_up = true
  client_id = *CENSORED*
  client_secret = *CENSORED*
  scopes = read_api
  auth_url = https://gitlab.com/oauth/authorize
  token_url = https://gitlab.com/oauth/token
  api_url = https://gitlab.com/api/v4
  ;allowed_domains =
  allowed_groups = kontur-private/platform

  [smtp]
  enabled = true
  host = email-smtp.eu-central-1.amazonaws.com:587
  user = *CENSORED*
  password = *CENSORED*
  from_address = admin@grafana02.kontur.io
  from_name = Grafana
  ehlo_identity = email-smtp.eu-central-1.amazonaws.com
  type: Opaque
```

But the object `secret/grafana-config` exists in cluster

```bash
(⎈ |rkireyeu@kontur.io:monitoring)➜ kubectl -n monitoring get secret/grafana-config
NAME             TYPE     DATA   AGE
grafana-config   Opaque   1      105d
(⎈ |rkireyeu@kontur.io:monitoring)➜
```
