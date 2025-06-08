# Prometheus SNMP Notifier

An Alertmanager webhook that relays alerts as SNMP traps.

This chart creates a [SNMP Notifier](https://github.com/maxwo/snmp_notifier) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.23+

## Get Repository Info

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

_See [helm repository](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

```console
helm install [RELEASE_NAME] prometheus-community/alertmanager-snmp-notifier
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

### Upgrading an existing Release to a new major version

A major chart version change (like v1.2.3 -> v2.0.0) indicates that there is an incompatible breaking change needing manual actions.

### To 1.0.0

This version uses SNMP Notifier 2.0.0, with the introduction of the generic `--trap.user-object` instead of `--snmp.trap-extra-field` arguments.

The chart therefore accepts the `trapTemplates` object with the `description` and `userObjects` variables instead of the previous `snmpTemplates`:

```yaml
trapTemplates:
    userObjects:
    - subOid: 1
        template: |
        {{- if .Alerts -}}
        Status: NOK
        {{- else -}}
        Status: OK
        {{- end -}}
    - subOid: 5
        template: |
        This is a constant
```

See [SNMP Notifier Repository](https://github.com/maxwo/snmp_notifier) for more details about new arguments.

It also updates the `HorizontalPodAutoscaler` to the `autoscaling/v2` API version.

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values prometheus-community/alertmanager-snmp-notifier
```

### Flags

Check the [configuration section](https://github.com/maxwo/snmp_notifier#snmp-notifier-configuration) list and add to the `snmpNotifier.extraArgs` block in your value overrides.
