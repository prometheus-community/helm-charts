# Prometheus Community Kubernetes Helm Charts

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Release status](https://github.com/prometheus-community/helm-charts/workflows/Release%20Charts/badge.svg?branch=main)](https://github.com/prometheus-community/helm-charts/actions/workflows/release.yaml?query=branch%3Amain)
[![Releases downloads](https://img.shields.io/github/downloads/prometheus-community/helm-charts/total.svg)](https://github.com/prometheus-community/helm-charts/releases)

This functionality is in beta and is subject to change. The code is provided as-is with no warranties. Beta features are not subject to the support SLA of official GA features.

## Usage

[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, you may install prometheus-community charts from either [OCI](#install-from-oci) or [HTTP](#install-from-http) repos.

## Install From OCI

[OCI support](https://helm.sh/docs/topics/registries/#using-an-oci-based-registry) is enabled by default as of of Helm `v3.8.0`.

- 👀 To see the prometheus-community charts in OCI, [browse the registry](https://github.com/orgs/prometheus-community/packages?repo_name=helm-charts)
- 🚀 To install a chart from the OCI registry:

  ```console
  helm install [RELEASE_NAME] oci://ghcr.io/prometheus-community/charts/[CHART_NAME]
  ```

- 🔐 Our OCI charts are secured with [cosign keyless signing](https://github.com/sigstore/cosign/blob/main/KEYLESS.md). You may verify a chart's authenticity with the [cosign CLI](https://github.com/sigstore/cosign/blob/main/README.md):

  ```console
  COSIGN_EXPERIMENTAL=1 cosign verify ghcr.io/prometheus-community/charts/[CHART_NAME]:[VERSION]
  ```

## Install From HTTP

HTTP [Helm repositories](https://helm.sh/docs/topics/charts/#chart-repositories) continue to be supported.

- ☝️ When using this method, you must first add the HTTP repository information to your Helm client:

  ```console
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update
  ```

- 👀 To see the prometheus-community charts in HTTP, run `helm search repo prometheus-community`

- 🚀 To install a chart from the HTTP repo:

  ```console
  helm install [RELEASE_NAME] prometheus-community/[CHART_NAME]
  ```

## Contributing

The source code of all [Prometheus](https://prometheus.io) community [Helm](https://helm.sh) charts can be found on Github: <https://github.com/prometheus-community/helm-charts/>

<!-- Keep full URL links to repo files because this README syncs from main to gh-pages.  -->
We'd love to have you contribute! Please refer to our [contribution guidelines](https://github.com/prometheus-community/helm-charts/blob/main/CONTRIBUTING.md) for details.

## License

<!-- Keep full URL links to repo files because this README syncs from main to gh-pages.  -->
[Apache 2.0 License](https://github.com/prometheus-community/helm-charts/blob/main/LICENSE).
