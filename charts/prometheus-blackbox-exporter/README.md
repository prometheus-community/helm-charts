# Prometheus Blackbox Exporter

Prometheus exporter for blackbox testing

Learn more: [https://github.com/prometheus/blackbox_exporter](https://github.com/prometheus/blackbox_exporter)

This chart creates a Blackbox-Exporter deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.8+ with Beta APIs enabled
- Helm >= 3.0

## Get Repository Info

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

_See [`helm repo`](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

```console
helm install [RELEASE_NAME] prometheus-community/prometheus-blackbox-exporter
```

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Uninstall Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Upgrading Chart

```console
helm upgrade [RELEASE_NAME] [CHART] --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

### To 11.0.0

This version removes support for the deprecated Kubernetes API `extensions/v1beta1`, `networking.k8s.io/v1beta1`, and `rbac.authorization.k8s.io/v1beta1`. and associated attributes.

### To 10.0.0

- `extraEnvFromSecret` got replaced with `extraEnvFrom`
- `extraEnv` handling got changed to use k8s env definitions as list of maps

### To 9.0.0

This version remove pod security policy as it is deprecated.

### To 8.0.0

- The default image is set to `quay.io/prometheus/blackbox-exporter` instead `prom/blackbox-exporter`
- `image.repository` is now split into `image.registry` and `image.repository`.
  For the old behavior, set `image.registry` to an empty string and only use `image.repository`.

### To 7.0.0

This version introduces the `securityContext` and `podSecurityContext` and removes `allowICMP`option.

All previous values are setup as default. In case that you want to enable previous functionality for `allowICMP` you need to explicit enabled with the following configuration:

```yaml
securityContext:
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    add: ["NET_RAW"]
```

### To 6.0.0

This version introduces the relabeling field for the ServiceMonitor.
All values in the list `additionalRelabeling` will now appear under `relabelings` instead of `metricRelabelings`.

### To 5.0.0

This version removes Helm 2 support. Also the ingress config has changed, so you have to adapt to the example in the values.yaml.

### To 4.0.0

This version create the service account by default and introduce pod security policy, it can be enabled by setting `pspEnabled: true`.

### To 2.0.0

This version removes the `podDisruptionBudget.enabled` parameter and changes the default value of `podDisruptionBudget` to `{}`, in order to fix Helm 3 compatibility.

In order to upgrade, please remove `podDisruptionBudget.enabled` from your custom values.yaml file and set the content of `podDisruptionBudget`, for example:

```yaml
podDisruptionBudget:
  maxUnavailable: 0
```

### To 1.0.0

This version introduce the new recommended labels.

In order to upgrade, delete the Deployment before upgrading:

```bash
kubectl delete deployment [RELEASE_NAME]-prometheus-blackbox-exporter
```

Note that this will cause downtime of the blackbox.

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values prometheus-community/prometheus-blackbox-exporter
```
