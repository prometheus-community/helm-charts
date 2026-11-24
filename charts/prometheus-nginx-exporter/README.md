# NGINX Prometheus Exporter

This chart bootstraps a [NGINX Prometheus Exporter](https://github.com/nginxinc/nginx-prometheus-exporter) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.19+ with Beta APIs enabled
- Helm 3

## Usage

The chart is distributed as an [OCI Artifact](https://helm.sh/docs/topics/registries/) as well as via a traditional [Helm Repository](https://helm.sh/docs/topics/chart_repository/).

- OCI Artifact: `oci://ghcr.io/prometheus-community/charts/prometheus-nginx-exporter`
- Helm Repository: `https://prometheus-community.github.io/helm-charts` with chart `prometheus-nginx-exporter`

The installation instructions use the OCI registry. Refer to the [`helm repo`](https://helm.sh/docs/helm/helm_repo/) command documentation for information on installing charts via the traditional repository.

### Install Chart

```console
helm install [RELEASE_NAME] oci://ghcr.io/prometheus-community/charts/prometheus-nginx-exporter
```

_See [configuration](#configuring) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

### Uninstall Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

### Upgrading Chart

```console
helm upgrade [RELEASE_NAME] oci://ghcr.io/prometheus-community/charts/prometheus-nginx-exporter --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

#### To 2.0.0

The exporter now runs with hardened defaults that follow the [restricted Pod Security Standard](https://kubernetes.io/docs/concepts/security/pod-security-standards/#restricted):

- `podSecurityContext`: `runAsNonRoot: true`, `runAsUser: 1001`, `runAsGroup: 1001` (the user of the upstream image) and `seccompProfile: RuntimeDefault`.
- `securityContext`: `allowPrivilegeEscalation: false`, all capabilities dropped and `readOnlyRootFilesystem: true`.
- `serviceAccount.automountServiceAccountToken` defaults to `false` and applies to the Pod and, when `serviceAccount.create` is `true`, to the ServiceAccount. The exporter does not call the Kubernetes API.

The `Role` and `RoleBinding` (and the `rbac.create` value) are removed. They granted `get` on `endpoints` to the Pod's ServiceAccount, which is the namespace's `default` ServiceAccount unless `serviceAccount.create` or `serviceAccount.name` is set, so every Pod using that ServiceAccount gained the permission. The exporter does not use it. Helm deletes both objects on upgrade.

The Pod spec changes, so the exporter restarts once on upgrade. If you run a custom image that needs a different user or a writable root filesystem, override `podSecurityContext` / `securityContext`. Setting them to `{}` keeps the defaults because Helm merges maps; set them to `null` (for example `--set podSecurityContext=null`) to remove them, or set individual keys to `null`.

#### To 1.0

Chart release 1.0 reflects a major bump of the default NGINX Exporter image tag from major number 0 to 1.

This release has switched to using flags in the new format (`--flag`) but still supports the
deprecated format (`-flag`) transparently for NGINX Exporter below release 1.0.0.

## Configuring

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values oci://ghcr.io/prometheus-community/charts/prometheus-nginx-exporter
```
