# kube-state-metrics Helm Chart

Installs the [kube-state-metrics agent](https://github.com/kubernetes/kube-state-metrics).

## Get Repo Info

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Compatibility matrix

### Helm Chart versions

This matrix shows the compatibility between the 5 latest chart releases with the 5 latest [Kubernetes releases](https://github.com/kubernetes/kubernetes/releases).

The compatibility is based on the Kubernetes API resources addition, deprecation and deletion.

| **Chart Version** | **Kubernetes 1.19** | **Kubernetes 1.20** | **Kubernetes 1.21** | **Kubernetes 1.22** | **Kubernetes 1.23** |
|-------------------|:-------------------:|:-------------------:|:-------------------:|:-------------------:|:-------------------:|
| **v4.7.x**        |         ✅          |         ✅          |         ✅          |         ✅          |         ✅          |
| **v4.6.x**        |         ✅          |         ✅          |         ✅          |         ✅          |         ✅          |
| **v4.5.x**        |         ✅          |         ✅          |         ✅          |         ✅          |         ✅          |
| **v4.4.x**        |         ✅          |         ✅          |         ✅          |         ✅          |         ✅          |
| **v4.3.x**        |         ✅          |         ✅          |         ✅          |         ✅          |         ✅          |

* ✅ : Fully compatible version
* ☑️ : Fully compatible version with deprecation warning(s)
* ⚠️ : Partially supported version
* ⛔️ : Unsupported version

This chart may be compatible with older versions of Kubernetes, you can use [kubepug](https://github.com/rikatz/kubepug) to test the compatibility.

### App(s) versions

While the Chart may be compatible with your Kubernetes version, the application may not be entirely.

This is the case for `kube-state-metrics` because it uses client-go to talk with Kubernetes clusters.\
Please make sure to also check the [kube-state-metrics compatibility matrix](https://github.com/kubernetes/kube-state-metrics/blob/master/README.md#kubernetes-version).

## Install Chart

```console
helm install [RELEASE_NAME] prometheus-community/kube-state-metrics [flags]
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
helm upgrade [RELEASE_NAME] prometheus-community/kube-state-metrics [flags]
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

### Migrating from stable/kube-state-metrics and kubernetes/kube-state-metrics

You can upgrade in-place:

1. [get repo info](#get-repo-info)
1. [upgrade](#upgrading-chart) your existing release name using the new chart repo

## Upgrading to v3.0.0

v3.0.0 includes kube-state-metrics v2.0, see the [changelog](https://github.com/kubernetes/kube-state-metrics/blob/release-2.0/CHANGELOG.md) for major changes on the application-side.

The upgraded chart now the following changes:

* Dropped support for helm v2 (helm v3 or later is required)
* collectors key was renamed to resources
* namespace key was renamed to namespaces

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments:

```console
helm show values prometheus-community/kube-state-metrics
```

You may also run `helm show values` on this chart's [dependencies](#dependencies) for additional options.
