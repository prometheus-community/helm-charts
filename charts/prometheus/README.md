# Prometheus

[Prometheus](https://prometheus.io/), a [Cloud Native Computing Foundation](https://cncf.io/) project, is a systems and service monitoring system. It collects metrics from configured targets at given intervals, evaluates rule expressions, displays the results, and can trigger alerts if some condition is observed to be true.

This chart bootstraps a [Prometheus](https://prometheus.io/) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.7+

## Get Repository Info

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

_See [helm repository](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

Starting with version 16.0, the Prometheus chart requires Helm 3.7+ in order to install successfully. Please check your `helm` release before installation.

```console
helm install [RELEASE_NAME] prometheus-community/prometheus
```

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Dependencies

By default this chart installs additional, dependent charts:

- [alertmanager](https://github.com/prometheus-community/helm-charts/tree/main/charts/alertmanager)
- [kube-state-metrics](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-state-metrics)
- [prometheus-node-exporter](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-node-exporter)
- [prometheus-pushgateway](https://github.com/walker-tom/helm-charts/tree/main/charts/prometheus-pushgateway)

To disable the dependency during installation, set `alertmanager.enabled`, `kube-state-metrics.enabled`, `prometheus-node-exporter.enabled` and `prometheus-pushgateway.enabled` to `false`.

_See [helm dependency](https://helm.sh/docs/helm/helm_dependency/) for command documentation._

## Uninstall Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Updating values.schema.json

A [`values.schema.json`](https://helm.sh/docs/topics/charts/#schema-files) file has been added to validate chart values. When `values.yaml` file has a structure change (i.e. add a new field, change value type, etc.), modify `values.schema.json` file manually or run `helm schema-gen values.yaml > values.schema.json` to ensure the schema is aligned with the latest values. Refer to [helm plugin `helm-schema-gen`](https://github.com/karuppiah7890/helm-schema-gen) for plugin installation instructions.

## Upgrading Chart

```console
helm upgrade [RELEASE_NAME] prometheus-community/prometheus --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

### To 27.0

Prometheus' configuration parameter `insecure_skip_verify` in scrape configs `serverFiles."prometheus.yml".scrape_configs` has been commented out keeping thus the default Prometheus' value.
If certificate verification must be skipped, please, uncomment the line before upgrading.

### To 26.0

This release changes default version of promethues to v3.0.0, See official [migration guide](https://prometheus.io/docs/prometheus/latest/migration/#prometheus-3-0-migration-guide
) and [release notes](https://github.com/prometheus/prometheus/releases/tag/v3.0.0) for more details.

### To 25.0

The `server.remoteRead[].url` and `server.remoteWrite[].url` fields now support templating. Allowing for `url` values such as `https://{{ .Release.Name }}.example.com`.

Any entries in these which previously included `{{` or `}}` must be escaped with `{{ "{{" }}` and `{{ "}}" }}` respectively. Entries which did not previously include the template-like syntax will not be affected.

### To 24.0

Require Kubernetes 1.19+

Release 1.0.0 of the _alertmanager_ replaced [configmap-reload](https://github.com/jimmidyson/configmap-reload) with [prometheus-config-reloader](https://github.com/prometheus-operator/prometheus-operator/tree/main/cmd/prometheus-config-reloader).
Extra command-line arguments specified via `configmapReload.prometheus.extraArgs` are not compatible and will break with the new prometheus-config-reloader. Please, refer to the [sources](https://github.com/prometheus-operator/prometheus-operator/blob/main/cmd/prometheus-config-reloader/main.go) in order to make the appropriate adjustment to the extra command-line arguments.

### To 23.0

Release 5.0.0 of the _kube-state-metrics_ chart introduced a separation of the `image.repository` value in two distinct values:

```console
 image:
   registry: registry.k8s.io
   repository: kube-state-metrics/kube-state-metrics
```

If a custom values file or CLI flags set `kube-state.metrics.image.repository`, please, set the new values accordingly.

If you are upgrading _prometheus-pushgateway_ with the chart and _prometheus-pushgateway_ has been deployed as a statefulset with a persistent volume, the statefulset must be deleted before upgrading the chart, e.g.:

```bash
kubectl delete sts -l app.kubernetes.io/name=prometheus-pushgateway -n monitoring --cascade=orphan
```

Users are advised to review changes in the corresponding chart releases before upgrading.

### To 22.0

The `app.kubernetes.io/version` label has been removed from the pod selector.

Therefore, you must delete the previous StatefulSet or Deployment before upgrading. Performing this operation will cause **Prometheus to stop functioning** until the upgrade is complete.

```console
kubectl delete deploy,sts -l app.kubernetes.io/name=prometheus
```

### To 21.0

The Kubernetes labels have been updated to follow [Helm 3 label and annotation best practices](https://helm.sh/docs/chart_best_practices/labels/).
Specifically, labels mapping is listed below:

| OLD                | NEW                          |
|--------------------|------------------------------|
|heritage            | app.kubernetes.io/managed-by |
|chart               | helm.sh/chart                |
|[container version] | app.kubernetes.io/version    |
|app                 | app.kubernetes.io/name       |
|release             | app.kubernetes.io/instance   |

Therefore, depending on the way you've configured the chart, the previous StatefulSet or Deployment need to be deleted before upgrade.

If `runAsStatefulSet: false` (this is the default):

```console
kubectl delete deploy -l app=prometheus
```

If `runAsStatefulSet: true`:

```console
kubectl delete sts -l app=prometheus
```

After that do the actual upgrade:

```console
helm upgrade -i prometheus prometheus-community/prometheus
```

### To 20.0

The [configmap-reload](https://github.com/jimmidyson/configmap-reload) container was replaced by the [prometheus-config-reloader](https://github.com/prometheus-operator/prometheus-operator/tree/main/cmd/prometheus-config-reloader).
Extra command-line arguments specified via configmapReload.prometheus.extraArgs are not compatible and will break with the new prometheus-config-reloader, refer to the [sources](https://github.com/prometheus-operator/prometheus-operator/blob/main/cmd/prometheus-config-reloader/main.go) in order to make the appropriate adjustment to the extra command-line arguments.

### To 19.0

Prometheus has been updated to version v2.40.5.

Prometheus-pushgateway was updated to version 2.0.0 which adapted [Helm label and annotation best practices](https://helm.sh/docs/chart_best_practices/labels/).
See the [upgrade docs of the prometheus-pushgateway chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-pushgateway#to-200) to see whats to do, before you upgrade Prometheus!

The condition in Chart.yaml to disable kube-state-metrics has been changed from `kubeStateMetrics.enabled` to `kube-state-metrics.enabled`

The Docker image tag is used from appVersion field in Chart.yaml by default.

Unused subchart configs has been removed and subchart config is now on the bottom of the config file.

If Prometheus is used as deployment the updatestrategy has been changed to "Recreate" by default, so Helm updates work out of the box.

`.Values.server.extraTemplates` & `.Values.server.extraObjects` has been removed in favour of `.Values.extraManifests`, which can do the same.

`.Values.server.enabled` has been removed as it's useless now that all components are created by subcharts.

All files in `templates/server` directory has been moved to `templates` directory.

```bash
helm upgrade [RELEASE_NAME] prometheus-community/prometheus --version 19.0.0
```

### To 18.0

Version 18.0.0 uses alertmanager service from the [alertmanager chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/alertmanager). If you've made some config changes, please check the old `alertmanager` and the new `alertmanager` configuration section in values.yaml for differences.

Note that the `configmapReload` section for `alertmanager` was moved out of dedicated section (`configmapReload.alertmanager`) to alertmanager embedded (`alertmanager.configmapReload`).

Before you update, please scale down the `prometheus-server` deployment to `0` then perform upgrade:

```bash
# In 17.x
kubectl scale deploy prometheus-server --replicas=0
# Upgrade
helm upgrade [RELEASE_NAME] prometheus-community/prometheus --version 18.0.0
```

### To 17.0

Version 17.0.0 uses pushgateway service from the [prometheus-pushgateway chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-pushgateway). If you've made some config changes, please check the old `pushgateway` and the new `prometheus-pushgateway` configuration section in values.yaml for differences.

Before you update, please scale down the `prometheus-server` deployment to `0` then perform upgrade:

```bash
# In 16.x
kubectl scale deploy prometheus-server --replicas=0
# Upgrade
helm upgrade [RELEASE_NAME] prometheus-community/prometheus --version 17.0.0
```

### To 16.0

Starting from version 16.0 embedded services (like alertmanager, node-exporter etc.) are moved out of Prometheus chart and the respecting charts from this repository are used as dependencies. Version 16.0.0 moves node-exporter service to [prometheus-node-exporter chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-node-exporter). If you've made some config changes, please check the old `nodeExporter` and the new `prometheus-node-exporter` configuration section in values.yaml for differences.

Before you update, please scale down the `prometheus-server` deployment to `0` then perform upgrade:

```bash
# In 15.x
kubectl scale deploy prometheus-server --replicas=0
# Upgrade
helm upgrade [RELEASE_NAME] prometheus-community/prometheus --version 16.0.0
```

### To 15.0

Version 15.0.0 changes the relabeling config, aligning it with the [Prometheus community conventions](https://github.com/prometheus/prometheus/pull/9832). If you've made manual changes to the relabeling config, you have to adapt your changes.

Before you update please execute the following command, to be able to update kube-state-metrics:

```bash
kubectl delete deployments.apps -l app.kubernetes.io/instance=prometheus,app.kubernetes.io/name=kube-state-metrics --cascade=orphan
```

### To 9.0

Version 9.0 adds a new option to enable or disable the Prometheus Server. This supports the use case of running a Prometheus server in one k8s cluster and scraping exporters in another cluster while using the same chart for each deployment. To install the server `server.enabled` must be set to `true`.

### To 5.0

As of version 5.0, this chart uses Prometheus 2.x. This version of prometheus introduces a new data format and is not compatible with prometheus 1.x. It is recommended to install this as a new release, as updating existing releases will not work. See the [prometheus docs](https://prometheus.io/docs/prometheus/latest/migration/#storage) for instructions on retaining your old data.

Prometheus version 2.x has made changes to alertmanager, storage and recording rules. Check out the migration guide [here](https://prometheus.io/docs/prometheus/2.0/migration/).

Users of this chart will need to update their alerting rules to the new format before they can upgrade.

### Example Migration

Assuming you have an existing release of the prometheus chart, named `prometheus-old`. In order to update to prometheus 2.x while keeping your old data do the following:

1. Update the `prometheus-old` release. Disable scraping on every component besides the prometheus server, similar to the configuration below:

  ```yaml
  alertmanager:
    enabled: false
  alertmanagerFiles:
    alertmanager.yml: ""
  kubeStateMetrics:
    enabled: false
  nodeExporter:
    enabled: false
  pushgateway:
    enabled: false
  server:
    extraArgs:
      storage.local.retention: 720h
  serverFiles:
    alerts: ""
    prometheus.yml: ""
    rules: ""
  ```

1. Deploy a new release of the chart with version 5.0+ using prometheus 2.x. In the values.yaml set the scrape config as usual, and also add the `prometheus-old` instance as a remote-read target.

   ```yaml
    prometheus.yml:
      ...
      remote_read:
      - url: http://prometheus-old/api/v1/read
      ...
   ```

   Old data will be available when you query the new prometheus instance.

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values prometheus-community/prometheus
```

You may similarly use the above configuration commands on each chart [dependency](#dependencies) to see its configurations.

### Scraping Pod Metrics via Annotations

This chart uses a default configuration that causes prometheus to scrape a variety of kubernetes resource types, provided they have the correct annotations. In this section we describe how to configure pods to be scraped; for information on how other resource types can be scraped you can do a `helm template` to get the kubernetes resource definitions, and then reference the prometheus configuration in the ConfigMap against the prometheus documentation for [relabel_config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#relabel_config) and [kubernetes_sd_config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#kubernetes_sd_config).

In order to get prometheus to scrape pods, you must add annotations to the pods as below:

```yaml
metadata:
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/path: /metrics
    prometheus.io/port: "8080"
```

You should adjust `prometheus.io/path` based on the URL that your pod serves metrics from. `prometheus.io/port` should be set to the port that your pod serves metrics from. Note that the values for `prometheus.io/scrape` and `prometheus.io/port` must be enclosed in double quotes.

### Sharing Alerts Between Services

Note that when [installing](#install-chart) or [upgrading](#upgrading-chart) you may use multiple values override files. This is particularly useful when you have alerts belonging to multiple services in the cluster. For example,

```yaml
# values.yaml
# ...

# service1-alert.yaml
serverFiles:
  alerts:
    service1:
      - alert: anAlert
      # ...

# service2-alert.yaml
serverFiles:
  alerts:
    service2:
      - alert: anAlert
      # ...
```

```console
helm install [RELEASE_NAME] prometheus-community/prometheus -f values.yaml -f service1-alert.yaml -f service2-alert.yaml
```

### RBAC Configuration

Roles and RoleBindings resources will be created automatically for `server` service.

To manually setup RBAC you need to set the parameter `rbac.create=false` and specify the service account to be used for each service by setting the parameters: `serviceAccounts.{{ component }}.create` to `false` and `serviceAccounts.{{ component }}.name` to the name of a pre-existing service account.

> **Tip**: You can refer to the default `*-clusterrole.yaml` and `*-clusterrolebinding.yaml` files in [templates](templates/) to customize your own.

### ConfigMap Files

AlertManager is configured through [alertmanager.yml](https://prometheus.io/docs/alerting/configuration/). This file (and any others listed in `alertmanagerFiles`) will be mounted into the `alertmanager` pod.

Prometheus is configured through [prometheus.yml](https://prometheus.io/docs/operating/configuration/). This file (and any others listed in `serverFiles`) will be mounted into the `server` pod.

### Ingress TLS

If your cluster allows automatic creation/retrieval of TLS certificates (e.g. [cert-manager](https://github.com/jetstack/cert-manager)), please refer to the documentation for that mechanism.

To manually configure TLS, first create/retrieve a key & certificate pair for the address(es) you wish to protect. Then create a TLS secret in the namespace:

```console
kubectl create secret tls prometheus-server-tls --cert=path/to/tls.cert --key=path/to/tls.key
```

Include the secret's name, along with the desired hostnames, in the alertmanager/server Ingress TLS section of your custom `values.yaml` file:

```yaml
server:
  ingress:
    ## If true, Prometheus server Ingress will be created
    ##
    enabled: true

    ## Prometheus server Ingress hostnames
    ## Must be provided if Ingress is enabled
    ##
    hosts:
      - prometheus.domain.com

    ## Prometheus server Ingress TLS configuration
    ## Secrets must be manually created in the namespace
    ##
    tls:
      - secretName: prometheus-server-tls
        hosts:
          - prometheus.domain.com
```

### NetworkPolicy

Enabling Network Policy for Prometheus will secure connections to Alert Manager and Kube State Metrics by only accepting connections from Prometheus Server. All inbound connections to Prometheus Server are still allowed.

To enable network policy for Prometheus, install a networking plugin that implements the Kubernetes NetworkPolicy spec, and set `networkPolicy.enabled` to true.

If NetworkPolicy is enabled for Prometheus' scrape targets, you may also need to manually create a networkpolicy which allows it.
