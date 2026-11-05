# Prometheus Community Kubernetes Helm Charts

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/prometheus-community)](https://artifacthub.io/packages/search?org=prometheus&cncf=true) [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Release Charts](https://github.com/prometheus-community/helm-charts/actions/workflows/release.yaml/badge.svg?branch=main) [![Releases downloads](https://img.shields.io/github/downloads/prometheus-community/helm-charts/total.svg)](https://github.com/prometheus-community/helm-charts/releases)

This functionality is in beta and is subject to change. The code is provided as-is with no warranties. Beta features are not subject to the support SLA of official GA features.

## Usage

[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, add the repository as follows:

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

You can then run `helm search repo prometheus-community` to see the charts.

OCI artifacts of all Prometheus Helm charts are available in [ghcr.io](https://github.com/orgs/prometheus-community/packages?repo_name=helm-charts).

## Helm Provenance and Integrity

All charts in this repository are signed. More information about how to verify charts can be found in the official [Helm documentation](https://helm.sh/docs/topics/provenance/).

A local running gpg agent is mandatory.

To import the signing key for this repository, please run the following command:

```console
curl https://prometheus-community.github.io/helm-charts/pubkey.gpg | gpg --import
```

After importing the key, you can use the `--verify` flag during `helm install` to enable chart signature validation.

## Contributing

The source code of all [Prometheus](https://prometheus.io) community [Helm](https://helm.sh) charts can be found on GitHub: <https://github.com/prometheus-community/helm-charts/>

<!-- Keep full URL links to repo files because this README syncs from main to gh-pages.  -->
We'd love to have you contribute! Please refer to our [contribution guidelines](https://github.com/prometheus-community/helm-charts/blob/main/CONTRIBUTING.md) for details.

## License

<!-- Keep full URL links to repo files because this README syncs from main to gh-pages.  -->
[Apache 2.0 License](https://github.com/prometheus-community/helm-charts/blob/main/LICENSE).

## Helm charts build status

![Release Charts](https://github.com/prometheus-community/helm-charts/actions/workflows/release.yaml/badge.svg?branch=main)
