# Prometheus Cloudwatch Exporter

An exporter for [Amazon CloudWatch](http://aws.amazon.com/cloudwatch/), for Prometheus.

This chart bootstraps a [cloudwatch exporter](http://github.com/prometheus/cloudwatch_exporter) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- An IAM role for the exporter through [IAM roles for service accounts (IRSA)](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) or [EKS Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html), or AWS credentials set with **aws.aws_access_key_id** and **aws.aws_secret_access_key** or **aws.secret.name**

## Usage

The chart is distributed as an [OCI Artifact](https://helm.sh/docs/topics/registries/) as well as via a traditional [Helm Repository](https://helm.sh/docs/topics/chart_repository/).

- OCI Artifact: `oci://ghcr.io/prometheus-community/charts/prometheus-cloudwatch-exporter`
- Helm Repository: `https://prometheus-community.github.io/helm-charts` with chart `prometheus-cloudwatch-exporter`

The installation instructions use the OCI registry. Refer to the [`helm repo`](https://helm.sh/docs/helm/helm_repo/) command documentation for information on installing charts via the traditional repository.

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

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus-cloudwatch-exporter/values.yaml), or run these configuration commands:

```console
# Helm 2
$ helm inspect values oci://ghcr.io/prometheus-community/charts/prometheus-cloudwatch-exporter

# Helm 3
$ helm show values oci://ghcr.io/prometheus-community/charts/prometheus-cloudwatch-exporter
```

### AWS Credentials or Role

For Cloudwatch Exporter to operate properly, you must configure either an IAM role or AWS credentials with the [correct policy](https://github.com/prometheus/cloudwatch_exporter#credentials-and-permissions).

- To use [IRSA](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html), set the service account annotation `eks.amazonaws.com/role-arn` to the role ARN. The chart writes `serviceAccount.annotations` onto the ServiceAccount when `serviceAccount.create` is `true` (the default). If you set `serviceAccount.create` to `false`, add that annotation on the existing ServiceAccount yourself:

  ```yaml
  serviceAccount:
    annotations:
      eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/[ROLE_NAME]
  ```

  `securityContext.runAsUser` and `securityContext.fsGroup` both default to `65534` so the pod can read the mounted token. If you change `securityContext.runAsUser`, set `securityContext.fsGroup` to the same value.
- To use [EKS Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html), associate the service account this chart runs with the role. No service account annotation and no `aws.role` value are required. Set `serviceAccount.name` only when the association should use a fixed name instead of the generated fullname.

  ```console
  $ aws eks create-pod-identity-association --cluster-name [CLUSTER_NAME] --namespace [NAMESPACE] --service-account [SERVICE_ACCOUNT_NAME] --role-arn [ROLE_ARN]
  ```
- To configure AWS credentials by value, set `aws.aws_access_key_id` to your [AWS_ACCESS_KEY_ID], and `aws.aws_secret_access_key` to [AWS_SECRET_ACCESS_KEY].
- To configure AWS credentials by secret, you must store them in a secret (`kubectl create secret generic [SECRET_NAME] --from-literal=access_key=[AWS_ACCESS_KEY_ID] --from-literal=secret_key=[AWS_SECRET_ACCESS_KEY]`) and set `aws.secret.name` to [SECRET_NAME]
- Legacy: `aws.role` only adds the pod annotation `iam.amazonaws.com/role`, which [kube2iam](https://github.com/jtblin/kube2iam) and [kiam](https://github.com/uswitch/kiam) read. Leave `aws.role` empty and use IRSA or EKS Pod Identity for new installs.
