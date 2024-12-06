# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---
## [Unreleased]
### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.27.1]
### Added
### Changed
### Deprecated
### Removed
### Fixed
- Remove default opensearch.yml config in Values.yaml to avoid security plugin conflicts
### Security
---
## [2.27.0]
### Added
- Updated OpenSearch appVersion to 2.18.0
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.26.1]
### Added
### Changed
### Deprecated
### Removed
### Fixed
- Resolved `helm lint` errors with extraObjects
### Security
---
## [2.26.0]
### Added
- Updated OpenSearch appVersion to 2.17.1
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.25.0]
### Added
- Updated OpenSearch appVersion to 2.17.0
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.24.1]
### Added
- Allow user-defined labels on persistent volume claim
### Changed
### Deprecated
### Removed
### Fixed
### Security
=======
## [2.24.0]
### Added
- Ability to add additional `labels` to `serviceMonitor`
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.23.2]
### Added
- Metrics configuration in both `Service` templates
### Changed
### Deprecated
### Removed
### Fixed
- Bug `protocol` missing for metrics in `Service`
### Security
---
## [2.23.1]
### Added
### Changed
### Deprecated
### Removed
### Fixed
- Fixed `ServiceMonitor` bug for `port` value
### Security
---
## [2.23.0]
### Added
- Added `ServiceMonitor` support for Prometheus monitoring
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.22.1]
### Added
### Changed
### Deprecated
### Removed
### Fixed
- Fixed opensearchJavaOpts defaults in README
### Security
---
## [2.22.0]
### Added
- Updated OpenSearch appVersion to 2.16.0
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.21.0]
### Added
- Updated OpenSearch appVersion to 2.15.0
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.20.0]
### Added
- Updated OpenSearch appVersion to 2.14.0
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.19.0]
### Added
- Updated OpenSearch appVersion to 2.13.0
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.18.0]
### Added
### Breaking
- Requires an initial admin password to be setup starting from App Version OpenSearch 2.12.0. Refer this github issue: https://github.com/opensearch-project/security/issues/3622
- Updated OpenSearch appVersion to 2.12.0
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.17.3]
### Added
### Changed
### Deprecated
### Removed
### Fixed
- Bug `opensearch.yml` configMap Read-only file system error.
### Security
---
## [2.17.2]
### Added
- - Allow user-defined labels on ingress resource
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.17.1]
### Added
- Added ability to specify custom pod anti-affinity and pod affinity
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.17.0]
### Added
- Updated OpenSearch appVersion to 2.11.1
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.16.1]
### Added
### Changed
### Deprecated
### Removed
### Fixed
- Fixed missing lifecycle parameter in README for opensearch chart
### Security
---
## [2.16.0]
### Added
- Updated OpenSearch appVersion to 2.11.0
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.15.0]
### Added
- Updated OpenSearch appVersion to 2.10.0
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.14.1]
### Added
- Add homepage and source urls to chart
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.14.0]
### Added
- Updated OpenSearch appVersion to 2.9.0
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.13.3]
### Added
### Changed
### Deprecated
### Removed
### Fixed
- Correct variable name in keystore import
### Security
---
## [2.13.2]
### Added
### Changed
### Deprecated
### Removed
### Fixed
- Avoid CrashLoop when keystore secret has no data
### Security
---
## [2.13.1]
### Added
- Support string type for extraObjects
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.13.0]
### Added
- Updated OpenSearch appVersion to 2.8.0
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.12.2]
### Added
- Support for toggling automountServiceAccountToken to comply with strict Kubernetes Policies
### Changed
- if/else logic for serviceAccountName to be more intelligent
### Deprecated
### Removed
### Fixed
- Whitespace under Resources blocks that was causing linting errors
### Security
---
## [2.12.1]
### Added
### Changed
### Deprecated
### Removed
### Fixed
- Add imagePullPolicy to fsgroup-volume init container
### Security
---
## [2.12.0]
### Added
- Updated OpenSearch appVersion to 2.7.0
### Changed
### Deprecated
### Removed
### Fixed
- Add imagePullPolicy to fsgroup-volume init container
### Security
---
## [2.11.5]
### Added
- Update the Readme and comments section.
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.11.4]
### Added
- Added custom opensearch deployment annotation through values.yaml
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.11.3]
### Added
- Support setting ipFamilyPolicy on Service
- Support setting ipFamilies on Service
---
## [2.11.2]
### Added
- Service ports for performance analyzer
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.11.1]
### Added
- Support for lifecycle in the opensearch container in the StatefulSet
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.11.0]
### Added
### Changed
- Updated OpenSearch appVersion to 2.6.0
### Deprecated
### Removed
### Fixed
### Security
---
## [2.10.0]
### Added
### Changed
- Updated OpenSearch appVersion to 2.5.0
### Deprecated
### Removed
### Fixed
### Security
---
## [2.9.1]
### Added
- Support for http- and transport-hostPort
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.9.0]
### Added
### Changed
- Updated OpenSearch appVersion to 2.4.1
### Deprecated
### Removed
### Fixed
### Security
---
## [2.8.2]
### Added
### Changed
### Deprecated
### Removed
### Fixed
- Fix path in securityConfig section, it was changed in ver.2. See: [Issue #127](https://github.com/opensearch-project/opensearch-plugins/issues/127)
### Security
---
## [2.8.1]
### Added
- added "plugins.enabled" and "plugins.installList" to the readme
### Changed
- Bumped version to 2.8.1
### Deprecated
### Removed
### Fixed
### Security
---
## [2.8.0]
### Added
### Changed
- Updated OpenSearch appVersion to 2.4.0
### Deprecated
### Removed
### Fixed
### Security
---
## [2.7.0]
### Added
- Add option to enable the use of `sysctlInit` to set sysctl vm.max_map_count through privileged `initContainer`. See: [Issue #87](https://github.com/opensearch-project/helm-charts/issues/87)
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.6.2]
### Added
- Liveness probe for statefulset
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.6.1]
### Added
- Template configmap content by tpl function
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.6.0]
### Added
### Changed
- Updated version to 2.6.0 and appVersion to "2.3.0".
### Deprecated
### Removed
### Fixed
### Security
---
## [2.5.1]
### Added
- Helm chart-releaser parallel release issue, updated version to 2.5.1.
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.5.0]
### Added
- Updated version to 2.5.0 and appVersion to "2.2.1".
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.4.1]
### Added
- Add "singleNode" feature to disable the "cluster.initial_master_nodes" env var
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.4.0]
### Added
- Updated version to 2.4.0 and appVersion to "2.2.0".
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.3.0]
### Added
- Updated version to 2.3.0 and appVersion to "2.1.0".
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.2.0]
### Added
- Add feature for readinessProbe and startupProbe
### Changed
### Deprecated
### Removed
### Fixed
### Security
---
## [2.1.0]
### Added
### Changed
- Updated version to 2.1.0 and appVersion to "2.0.1".
### Deprecated
### Removed
### Fixed
### Security
---
## [2.0.1]
### Added
### Changed
- Updated version to 2.0.1 and appVersion to "2.0.0".
### Deprecated
### Removed
### Fixed
### Security
---
## [2.0.0]
### Added
### Changed
- Updated version to 2.0.0 and appVersion to "2.0.0-rc1".
### Deprecated
### Removed
### Fixed
### Security

[Unreleased]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.27.1...HEAD
[2.27.1]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.27.0...opensearch-2.27.1
[2.27.0]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.26.1...opensearch-2.27.0
[2.26.1]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.26.0...opensearch-2.26.1
[2.26.0]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.25.0...opensearch-2.26.0
[2.25.0]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.24.1...opensearch-2.25.0
[2.24.1]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.24.0...opensearch-2.24.1
[2.24.0]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.23.1...opensearch-2.24.0
[2.23.2]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.23.1...opensearch-2.23.2
[2.23.1]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.23.0...opensearch-2.23.1
[2.23.0]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.22.1...opensearch-2.23.0
[2.22.1]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.22.0...opensearch-2.22.1
[2.22.0]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.21.0...opensearch-2.22.0
[2.21.0]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.20.0...opensearch-2.21.0
[2.20.0]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.19.0...opensearch-2.20.0
[2.19.0]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.18.0...opensearch-2.19.0
[2.18.0]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.17.3...opensearch-2.18.0
[2.17.3]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.17.2...opensearch-2.17.3
[2.17.2]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.17.1...opensearch-2.17.2
[2.17.1]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.17.0...opensearch-2.17.1
[2.17.0]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.16.1...opensearch-2.17.0
[2.16.1]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.16.0...opensearch-2.16.1
[2.16.0]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.15.0...opensearch-2.16.0
[2.15.0]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.14.1...opensearch-2.15.0
[2.14.1]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.14.0...opensearch-2.14.1
[2.14.0]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.13.3...opensearch-2.14.0
[2.13.3]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.13.1...opensearch-2.13.3
[2.13.2]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.13.1...opensearch-2.13.2
[2.13.1]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.13.0...opensearch-2.13.1
[2.13.0]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.12.0...opensearch-2.13.0
[2.12.0]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.11.5...opensearch-2.12.0
[2.11.5]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.11.4...opensearch-2.11.5
[2.11.4]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.11.3...opensearch-2.11.4
[2.11.3]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.11.2...opensearch-2.11.3
[2.11.2]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.11.1...opensearch-2.11.2
[2.11.1]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.11.0...opensearch-2.11.1
[2.11.0]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.10.0...opensearch-2.11.0
[2.10.0]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.9.1...opensearch-2.10.0
[2.9.1]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.9.0...opensearch-2.9.1
[2.9.0]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.8.2...opensearch-2.9.0
[2.8.2]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.8.1...opensearch-2.8.2
[2.8.1]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.8.0...opensearch-2.8.1
[2.8.0]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.7.0...opensearch-2.8.0
[2.7.0]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.6.1...opensearch-2.7.0
[2.6.2]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.6.1...opensearch-2.6.2
[2.6.1]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.6.0...opensearch-2.6.1
[2.6.0]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.5.0...opensearch-2.6.0
[2.5.1]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.5.0...opensearch-2.5.1
[2.5.0]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.4.1...opensearch-2.5.0
[2.4.1]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.4.0...opensearch-2.4.1
[2.4.0]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.3.0...opensearch-2.4.0
[2.3.0]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.2.0...opensearch-2.3.0
[2.2.0]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.1.0...opensearch-2.2.0
[2.1.0]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.0.1...opensearch-2.1.0
[2.0.1]: https://github.com/opensearch-project/helm-charts/compare/opensearch-2.0.0...opensearch-2.0.1
