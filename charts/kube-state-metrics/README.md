# kube-state-metrics Helm Chart

Installs the [kube-state-metrics agent](https://github.com/kubernetes/kube-state-metrics).

## Usage

The chart is distributed as an [OCI Artifact](https://helm.sh/docs/topics/registries/) as well as via a traditional [Helm Repository](https://helm.sh/docs/topics/chart_repository/).

- OCI Artifact: `oci://ghcr.io/prometheus-community/charts/kube-state-metrics`
- Helm Repository: `https://prometheus-community.github.io/helm-charts` with chart `kube-state-metrics`

The installation instructions use the OCI registry. Refer to the [`helm repo`]([`helm repo`](https://helm.sh/docs/helm/helm_repo/)) command documentation for information on installing charts via the traditional repository.

### Install Chart

```console
helm install [RELEASE_NAME] oci://ghcr.io/prometheus-community/charts/kube-state-metrics [flags]
```

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

### Uninstall Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

### Upgrading Chart

```console
helm upgrade [RELEASE_NAME] oci://ghcr.io/prometheus-community/charts/kube-state-metrics [flags]
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

#### Migrating from stable/kube-state-metrics and kubernetes/kube-state-metrics

You can upgrade in-place:

1. [upgrade](#upgrading-chart) your existing release name using the new chart repository

## Upgrading to v8.0.0

This version drops support for configuring `CiliumNetworkPolicy` as it is a vendor specific resource.
In addition, the `networkPolicy.flavor` setting is no longer persistent and can be safely dropped as only Kubernetes `NetworkPolicy` resources are supported.

## Upgrading to v6.0.0

This version drops support for deprecated Pod Security Policy resources.

## Upgrading to v3.0.0

v3.0.0 includes kube-state-metrics v2.0, see the [changelog](https://github.com/kubernetes/kube-state-metrics/blob/release-2.0/CHANGELOG.md) for major changes on the application-side.

The upgraded chart now the following changes:

- Dropped support for helm v2 (helm v3 or later is required)
- collectors key was renamed to resources
- namespace key was renamed to namespaces

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments:

```console
helm show values oci://ghcr.io/prometheus-community/charts/kube-state-metrics
```

### Admission policy collectors

kube-state-metrics v2.20.0 and later supports the following admission policy collectors.
They use the `admissionregistration.k8s.io/v1` API and are opt-in in this chart to preserve compatibility with older Kubernetes versions and image overrides.

| Collectors | Required Kubernetes version |
| --- | --- |
| `validatingadmissionpolicies`, `validatingadmissionpolicybindings` | [v1.30 or later](https://kubernetes.io/docs/reference/access-authn-authz/validating-admission-policy/) |
| `mutatingadmissionpolicies`, `mutatingadmissionpolicybindings` | [v1.36 or later](https://kubernetes.io/docs/reference/access-authn-authz/mutating-admission-policy/) |

Enable only the collectors supported by your cluster through `collectorsExtra` or `collectors`.
For example, on Kubernetes v1.36 or later:

```yaml
collectorsExtra:
  - mutatingadmissionpolicies
  - mutatingadmissionpolicybindings
  - validatingadmissionpolicies
  - validatingadmissionpolicybindings
```

On Kubernetes v1.30 through v1.35, enable only the two validating admission policy collectors.
Do not enable these collectors when overriding the image to a kube-state-metrics version older than v2.20.0.

These resources are cluster-scoped and require cluster-wide RBAC permissions.
With the default RBAC settings, the chart adds `list` and `watch` permissions only for the selected collectors.
If you manage RBAC separately, grant those permissions on the selected resources in the `admissionregistration.k8s.io` API group.

### kube-rbac-proxy

You can enable `kube-state-metrics` endpoint protection using `kube-rbac-proxy`. By setting `kubeRBACProxy.enabled: true`, this chart will deploy one RBAC proxy container per endpoint (metrics & telemetry).
To authorize access, authenticate your requests (via a `ServiceAccount` for example) with a `ClusterRole` attached such as:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kube-state-metrics-read
rules:
  - apiGroups: [ "" ]
    resources: ["services/kube-state-metrics"]
    verbs:
      - get
```

See [kube-rbac-proxy examples](https://github.com/brancz/kube-rbac-proxy/tree/master/examples/resource-attributes) for more details.

### auth-filter

As an alternative to `kube-rbac-proxy`, `kube-state-metrics` can authenticate and authorize requests itself using its built-in `--auth-filter`. Set `authFilter.enabled: true` to add the `--auth-filter` flag and the `create` permissions on `tokenreviews` and `subjectaccessreviews` that the filter requires.

Scrapers must then authenticate (for example via a `ServiceAccount` token) and be authorized to `get` the `kube-state-metrics` service. See the upstream [Authentication / Authorization](https://github.com/kubernetes/kube-state-metrics/blob/main/docs/README.md#protecting-metrics-endpoints) documentation for the scraper-side `ClusterRole` and `ClusterRoleBinding`.
