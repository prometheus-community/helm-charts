# prom-label-proxy

A proxy that enforces a given label in a given PromQL query.

**Homepage:** <https://github.com/oci://ghcr.io/prometheus-community/charts/prom-label-proxy>

## Usage

The chart is distributed as an [OCI Artifact](https://helm.sh/docs/topics/registries/) as well as via a traditional [Helm Repository](https://helm.sh/docs/topics/chart_repository/).

- OCI Artifact: `oci://ghcr.io/prometheus-community/charts/prom-label-proxy`
- Helm Repository: `https://prometheus-community.github.io/helm-charts` with chart `prom-label-proxy`

The installation instructions use the OCI registry. Refer to the [`helm repo`]([`helm repo`](https://helm.sh/docs/helm/helm_repo/)) command documentation for information on installing charts via the traditional repository.

### Install Chart

```console
helm install [RELEASE_NAME] oci://ghcr.io/prometheus-community/charts/prom-label-proxy
```

_See [configuration](#configuration) below._

_See [`helm install`](https://helm.sh/docs/helm/helm_install/) for command documentation._

### Uninstall Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [`helm uninstall`](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

### Upgrading Chart

```console
helm upgrade [RELEASE_NAME] [CHART] --install
```

_See [`helm upgrade`](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values oci://ghcr.io/prometheus-community/charts/prom-label-proxy
```

### kube-rbac-proxy

You can enable `prom-label-proxy` endpoint protection using `kube-rbac-proxy`. By setting `kubeRBACProxy.enabled: true`, this chart will deploy one RBAC proxy container for `config.listenAddress`.

With the below example `values.yaml` :

```yaml
config:
  upstream: http://prometheus:9090
  extraArgs:
  - --enable-label-apis=true
  - --header-name=X-Namespace

kubeRBACProxy:
  enabled: true
  config:
    authorization:
      rewrites:
        byHttpHeader:
          name: X-Namespace
      resourceAttributes:
        apiVersion: v1
        resource: namespaces
        subresource: metrics
        namespace: "{{ .Value }}"
```

To authorize access, authenticate your requests (via a `ServiceAccount` for example) with a `Role` attached such as:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tenant1-metrics-reader
  namespace: tenant1
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: tenant1-metrics
  namespace: tenant1
rules:
  - apiGroups: [ '' ]
    resources:
      - namespaces/metrics
    verbs: [ "create", "get" ]
---
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: tenant1-metrics-reader
  namespace: tenant1
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: tenant1-metrics
subjects:
- kind: ServiceAccount
  name: tenant1-metrics-reader
  namespace: tenant1
```

See [kube-rbac-proxy examples](https://github.com/brancz/kube-rbac-proxy/tree/master/examples/rewrites) for more details.
