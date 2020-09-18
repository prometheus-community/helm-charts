# kube-prometheus-stack

Installs the [kube-prometheus stack](https://github.com/prometheus-operator/kube-prometheus), a collection of Kubernetes manifests, [Grafana](http://grafana.com/) dashboards, and [Prometheus rules](https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/) combined with documentation and scripts to provide easy to operate end-to-end Kubernetes cluster monitoring with [Prometheus](https://prometheus.io/) using the [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator).

See the [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus) README for details about components, dashboards, and alerts.

_Note: This chart was formerly named `prometheus-operator` chart, now renamed to more clearly reflect that it installs the `kube-prometheus` project stack, within which Prometheus Operator is only one component._

## Prerequisites

- Kubernetes 1.10+ with Beta APIs
- Helm 2.12+ (If using Helm < 2.14, [see below for CRD workaround](#Helm-fails-to-create-CRDs))

## Get Repo Info

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update
```

_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

```console
# Helm 3
$ helm install [RELEASE_NAME] prometheus-community/kube-prometheus-stack

# Helm 2
$ helm install --name [RELEASE_NAME] prometheus-community/kube-prometheus-stack
```

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Dependencies

By default this chart installs additional, dependent charts:

- [stable/kube-state-metrics](https://github.com/helm/charts/tree/master/stable/kube-state-metrics)
- [stable/prometheus-node-exporter](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-node-exporter)
- [grafana/grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana)

To disable dependencies during installation, see [multiple releases](#multiple-releases) below.

_See [helm dependency](https://helm.sh/docs/helm/helm_dependency/) for command documentation._

## Uninstall Chart

```console
# Helm 3
$ helm uninstall [RELEASE_NAME]

# Helm 2
# helm delete --purge [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

CRDs created by this chart are not removed by default and should be manually cleaned up:

```console
kubectl delete crd prometheuses.monitoring.coreos.com
kubectl delete crd prometheusrules.monitoring.coreos.com
kubectl delete crd servicemonitors.monitoring.coreos.com
kubectl delete crd podmonitors.monitoring.coreos.com
kubectl delete crd alertmanagers.monitoring.coreos.com
kubectl delete crd thanosrulers.monitoring.coreos.com
```

## Upgrading Chart

```console
# Helm 3 or 2
$ helm upgrade [RELEASE_NAME] prometheus-community/kube-prometheus-stack
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

### Upgrading an existing Release to a new major version

A major chart version change (like v1.2.3 -> v2.0.0) indicates that there is an incompatible breaking change needing manual actions.

### From 8.x to 9.x

Version 9 of the helm chart removes the existing `additionalScrapeConfigsExternal` in favour of `additionalScrapeConfigsSecret`. This change lets users specify the secret name and secret key to use for the additional scrape configuration of prometheus. This is useful for users that have prometheus-operator as a subchart and also have a template that creates the additional scrape configuration.

### From 7.x to 8.x

Due to new template functions being used in the rules in version 8.x.x of the chart, an upgrade to Prometheus Operator and Prometheus is necessary in order to support them. First, upgrade to the latest version of 7.x.x

```sh
helm upgrade [RELEASE_NAME] prometheus-community/kube-prometheus-stack --version 7.5.0
```

Then upgrade to 8.x.x

```sh
helm upgrade [RELEASE_NAME] prometheus-community/kube-prometheus-stack --version [8.x.x]
```

Minimal recommended Prometheus version for this chart release is `2.12.x`

### From 6.x to 7.x

Due to a change in grafana subchart, version 7.x.x now requires Helm >= 2.12.0.

### From 5.x to 6.x

Due to a change in deployment labels of kube-state-metrics, the upgrade requires `helm upgrade --force` in order to re-create the deployment. If this is not done an error will occur indicating that the deployment cannot be modified:

```console
invalid: spec.selector: Invalid value: v1.LabelSelector{MatchLabels:map[string]string{"app.kubernetes.io/name":"kube-state-metrics"}, MatchExpressions:[]v1.LabelSelectorRequirement(nil)}: field is immutable
```

If this error has already been encountered, a `helm history` command can be used to determine which release has worked, then `helm rollback` to the release, then `helm upgrade --force` to this new one

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments:

```console
helm show values prometheus-community/kube-prometheus-stack
```

You may also `helm show values` on this chart's [dependencies](#dependencies) for additional options.

### Multiple releases

The same chart can be used to run multiple Prometheus instances in the same cluster if required. To achieve this, it is necessary to run only one instance of prometheus-operator and a pair of alertmanager pods for an HA configuration, while all other components need to be disabled. To disable a dependency during installation, set `kubeStateMetrics.enabled`, `nodeExporter.enabled` and `grafana.enabled` to `false`.

## Work-Arounds for Known Issues

### Running on private GKE clusters

When Google configure the control plane for private clusters, they automatically configure VPC peering between your Kubernetes cluster’s network and a separate Google managed project. In order to restrict what Google are able to access within your cluster, the firewall rules configured restrict access to your Kubernetes pods. This means that in order to use the webhook component with a GKE private cluster, you must configure an additional firewall rule to allow the GKE control plane access to your webhook pod.

You can read more information on how to add firewall rules for the GKE control plane nodes in the [GKE docs](https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters#add_firewall_rules)

Alternatively, you can disable the hooks by setting `prometheusOperator.admissionWebhooks.enabled=false`.

### Helm fails to create CRDs

You should upgrade to Helm 2.14 + in order to avoid this issue. However, if you are stuck with an earlier Helm release you should instead use the following approach: Due to a bug in helm, it is possible for the 5 CRDs that are created by this chart to fail to get fully deployed before Helm attempts to create resources that require them. This affects all versions of Helm with a [potential fix pending](https://github.com/helm/helm/pull/5112). In order to work around this issue when installing the chart you will need to make sure all 5 CRDs exist in the cluster first and disable their previsioning by the chart:

1. Create CRDs

    ```console
    kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/release-0.38/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
    kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/release-0.38/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
    kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/release-0.38/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
    kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/release-0.38/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
    kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/release-0.38/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
    kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/release-0.38/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
    ```

2. Wait for CRDs to be created, which should only take a few seconds
3. [Install](#install-chart) the chart, but disable the CRD provisioning by setting `prometheusOperator.createCustomResource` to `false`

## PrometheusRules Admission Webhooks

With Prometheus Operator version 0.30+, the core Prometheus Operator pod exposes an endpoint that will integrate with the `validatingwebhookconfiguration` Kubernetes feature to prevent malformed rules from being added to the cluster.

### How the Chart Configures the Hooks

A validating and mutating webhook configuration requires the endpoint to which the request is sent to use TLS. It is possible to set up custom certificates to do this, but in most cases, a self-signed certificate is enough. The setup of this component requires some more complex orchestration when using helm. The steps are created to be idempotent and to allow turning the feature on and off without running into helm quirks.

1. A pre-install hook provisions a certificate into the same namespace using a format compatible with provisioning using end-user certificates. If the certificate already exists, the hook exits.
2. The prometheus operator pod is configured to use a TLS proxy container, which will load that certificate.
3. Validating and Mutating webhook configurations are created in the cluster, with their failure mode set to Ignore. This allows rules to be created by the same chart at the same time, even though the webhook has not yet been fully set up - it does not have the correct CA field set.
4. A post-install hook reads the CA from the secret created by step 1 and patches the Validating and Mutating webhook configurations. This process will allow a custom CA provisioned by some other process to also be patched into the webhook configurations. The chosen failure policy is also patched into the webhook configurations

### Alternatives

It should be possible to use [jetstack/cert-manager](https://github.com/jetstack/cert-manager) if a more complete solution is required, but it has not been tested.

### Limitations

Because the operator can only run as a single pod, there is potential for this component failure to cause rule deployment failure. Because this risk is outweighed by the benefit of having validation, the feature is enabled by default.

## Developing Prometheus Rules and Grafana Dashboards

This chart Grafana Dashboards and Prometheus Rules are just a copy from [prometheus-operator/prometheus-operator](https://github.com/prometheus-operator/prometheus-operator) and other sources, synced (with alterations) by scripts in [hack](hack) folder. In order to introduce any changes you need to first [add them to the original repo](https://github.com/prometheus-operator/kube-prometheus/blob/master/docs/developing-prometheus-rules-and-grafana-dashboards.md) and then sync there by scripts.

## Further Information

For more in-depth documentation of configuration options meanings, please see

- [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator)
- [Prometheus](https://prometheus.io/docs/introduction/overview/)
- [Grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart)

## prometheus.io/scrape

The prometheus operator does not support annotation-based discovery of services, using the `serviceMonitor` CRD in its place as it provides far more configuration options. For information on how to use servicemonitors, please see the documentation on the `prometheus-operator/prometheus-operator` documentation here: [Running Exporters](https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/user-guides/running-exporters.md)

By default, Prometheus discovers ServiceMonitors within its namespace, that are labeled with the same release tag as the prometheus-operator release. Sometimes, you may need to discover custom ServiceMonitors, for example used to scrape data from third-party applications. An easy way of doing this, without compromising the default ServiceMonitors discovery, is allowing Prometheus to discover all ServiceMonitors within its namespace, without applying label filtering. To do so, you can set `prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues` to `false`.

## Migrating from coreos/prometheus-operator chart

The multiple charts have been combined into a single chart that installs prometheus operator, prometheus, alertmanager, grafana as well as the multitude of exporters necessary to monitor a cluster.

There is no simple and direct migration path between the charts as the changes are extensive and intended to make the chart easier to support.

The capabilities of the old chart are all available in the new chart, including the ability to run multiple prometheus instances on a single cluster - you will need to disable the parts of the chart you do not wish to deploy.

You can check out the tickets for this change [here](https://github.com/prometheus-operator/prometheus-operator/issues/592) and [here](https://github.com/helm/charts/pull/6765).

### High-level overview of Changes

#### Added dependencies

The chart has added 3 [dependencies](#dependencies).

- Node-Exporter, Kube-State-Metrics: These components are loaded as dependencies into the chart, and are relatively simple components
- Grafana: The Grafana chart is more feature-rich than this chart - it contains a sidecar that is able to load data sources and dashboards from configmaps deployed into the same cluster. For more information check out the [documentation for the chart](https://github.com/helm/charts/tree/master/stable/grafana)

#### CoreOS CRDs

The CRDs are provisioned using crd-install hooks, rather than relying on a separate chart installation. If you already have these CRDs provisioned and don't want to remove them, you can disable the CRD creation by these hooks by setting `prometheusOperator.createCustomResource` to `false` (not required if using Helm v3).

#### Kubelet Service

Because the kubelet service has a new name in the chart, make sure to clean up the old kubelet service in the `kube-system` namespace to prevent counting container metrics twice.

#### Persistent Volumes

If you would like to keep the data of the current persistent volumes, it should be possible to attach existing volumes to new PVCs and PVs that are created using the conventions in the new chart. For example, in order to use an existing Azure disk for a helm release called `prometheus-migration` the following resources can be created:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pvc-prometheus-migration-prometheus-0
spec:
  accessModes:
  - ReadWriteOnce
  azureDisk:
    cachingMode: None
    diskName: pvc-prometheus-migration-prometheus-0
    diskURI: /subscriptions/f5125d82-2622-4c50-8d25-3f7ba3e9ac4b/resourceGroups/sample-migration-resource-group/providers/Microsoft.Compute/disks/pvc-prometheus-migration-prometheus-0
    fsType: ""
    kind: Managed
    readOnly: false
  capacity:
    storage: 1Gi
  persistentVolumeReclaimPolicy: Delete
  storageClassName: prometheus
  volumeMode: Filesystem
```

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  labels:
    app: prometheus
    prometheus: prometheus-migration-prometheus
  name: prometheus-prometheus-migration-prometheus-db-prometheus-prometheus-migration-prometheus-0
  namespace: monitoring
spec:
  accessModes:
  - ReadWriteOnce
  dataSource: null
  resources:
    requests:
      storage: 1Gi
  storageClassName: prometheus
  volumeMode: Filesystem
  volumeName: pvc-prometheus-migration-prometheus-0
status:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 1Gi
```

The PVC will take ownership of the PV and when you create a release using a persistent volume claim template it will use the existing PVCs as they match the naming convention used by the chart. For other cloud providers similar approaches can be used.

#### KubeProxy

The metrics bind address of kube-proxy is default to `127.0.0.1:10249` that prometheus instances **cannot** access to. You should expose metrics by changing `metricsBindAddress` field value to `0.0.0.0:10249` if you want to collect them.

Depending on the cluster, the relevant part `config.conf` will be in ConfigMap `kube-system/kube-proxy` or `kube-system/kube-proxy-config`. For example:

```console
kubectl -n kube-system edit cm kube-proxy
```

```yaml
apiVersion: v1
data:
  config.conf: |-
    apiVersion: kubeproxy.config.k8s.io/v1alpha1
    kind: KubeProxyConfiguration
    # ...
    # metricsBindAddress: 127.0.0.1:10249
    metricsBindAddress: 0.0.0.0:10249
    # ...
  kubeconfig.conf: |-
    # ...
kind: ConfigMap
metadata:
  labels:
    app: kube-proxy
  name: kube-proxy
  namespace: kube-system
```
