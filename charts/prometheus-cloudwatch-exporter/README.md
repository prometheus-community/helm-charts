# Prometheus Cloudwatch Exporter

An exporter for [Amazon CloudWatch](http://aws.amazon.com/cloudwatch/), for Prometheus.

This chart bootstraps a [cloudwatch exporter](http://github.com/prometheus/cloudwatch_exporter) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- [kube2iam](../../stable/kube2iam) installed to used the **aws.role** config option otherwise configure **aws.aws_access_key_id** and **aws.aws_secret_access_key** or **aws.secret.name**
- Or an [IAM Role for service account](https://aws.amazon.com/blogs/opensource/introducing-fine-grained-iam-roles-service-accounts/) attached to a service account with an annotation. If you run the pod as nobody in `securityContext.runAsUser` then also set `securityContext.fsGroup` to the same value so it will be able to access to the mounted secret.

## Usage

The chart is distributed as an [OCI Artifact](https://helm.sh/docs/topics/registries/) as well as via a traditional [Helm Repository](https://helm.sh/docs/topics/chart_repository/).

- OCI Artifact: `oci://ghcr.io/prometheus-community/charts/prometheus-cloudwatch-exporter`
- Helm Repository: `https://prometheus-community.github.io/helm-charts` with chart `prometheus-cloudwatch-exporter`

The installation instructions use the OCI registry. Refer to the [`helm repo`]([`helm repo`](https://helm.sh/docs/helm/helm_repo/)) command documentation for information on installing charts via the traditional repository.

### Install Chart

```console
# Helm 3
$ helm install [RELEASE_NAME] oci://ghcr.io/prometheus-community/charts/prometheus-cloudwatch-exporter

# Helm 2
$ helm install --name [RELEASE_NAME] oci://ghcr.io/prometheus-community/charts/prometheus-cloudwatch-exporter
```

_See [Configuring](#configuring) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

### Uninstall Chart

```console
# Helm 3
$ helm uninstall [RELEASE_NAME]

# Helm 2
# helm delete --purge [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

### Upgrading Chart

```console
# Helm 3 or 2
$ helm upgrade [RELEASE_NAME] [CHART] --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

## Configuring

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
# Helm 2
$ helm inspect values oci://ghcr.io/prometheus-community/charts/prometheus-cloudwatch-exporter

# Helm 3
$ helm show values oci://ghcr.io/prometheus-community/charts/prometheus-cloudwatch-exporter
```

### AWS Credentials or Role

For Cloudwatch Exporter to operate properly, you must configure either AWS credentials or an AWS role with the [correct policy](https://github.com/prometheus/cloudwatch_exporter#credentials-and-permissions).

- To configure AWS credentials by value, set `aws.aws_access_key_id` to your [AWS_ACCESS_KEY_ID], and `aws.aws_secret_access_key` to [AWS_SECRET_ACCESS_KEY].
- To configure AWS credentials by secret, you must store them in a secret (`kubectl create secret generic [SECRET_NAME] --from-literal=access_key=[AWS_ACCESS_KEY_ID] --from-literal=secret_key=[AWS_SECRET_ACCESS_KEY]`) and set `aws.secret.name` to [SECRET_NAME]
- To configure an AWS role (with correct policy linked above), set `aws.role` to [ROLE_NAME]
