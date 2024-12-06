# opencti

A Helm chart to deploy Open Cyber Threat Intelligence platform

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| ialejandro | <hello@ialejandro.rocks> | <https://ialejandro.rocks> |

## Prerequisites

* Helm 3+

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://opensearch-project.github.io/helm-charts/ | opensearch | 2.27.1 |
| oci://registry-1.docker.io/bitnamicharts | elasticsearch | 21.3.26 |
| oci://registry-1.docker.io/bitnamicharts | minio | 14.8.5 |
| oci://registry-1.docker.io/bitnamicharts | rabbitmq | 15.1.0 |
| oci://registry-1.docker.io/bitnamicharts | redis | 20.3.0 |

## Add repository

```console
helm repo add opencti https://devops-ia.github.io/helm-opencti
helm repo update
```

## Install Helm chart (repository mode)

```console
helm install [RELEASE_NAME] opencti/opencti
```

This install all the Kubernetes components associated with the chart and creates the release.

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Install Helm chart (OCI mode)

Charts are also available in OCI format. The list of available charts can be found [here](https://github.com/devops-ia/helm-opencti/pkgs/container/helm-opencti%2Fopencti).

```console
helm install [RELEASE_NAME] oci://ghcr.io/devops-ia/helm-opencti/opencti --version=[version]
```

## Uninstall Helm chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## OpenCTI

* [Environment configuration](https://docs.opencti.io/latest/deployment/configuration/#platform)
* [Connectors](https://github.com/OpenCTI-Platform/connectors/tree/master). Review `docker-compose.yaml` with the properly config
* Check connectors samples on [`connector-examples`](./connector-examples) folder

## Basic installation and examples

See [basic installation](docs/configuration.md) and [examples](docs/examples.md).

## Configuration

See [Customizing the chart before installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with comments:

```console
helm show values opencti/opencti
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for pod assignment </br> Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity |
| autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Autoscaling with CPU or memory utilization percentage </br> Ref: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/ |
| connectors | list | `[]` | Connectors </br> Ref: https://github.com/OpenCTI-Platform/connectors/tree/master |
| connectorsGlobal | object | `{"env":{},"envFromSecrets":{},"volumeMounts":[],"volumes":[]}` | Connectors Globals |
| connectorsGlobal.env | object | `{}` | Additional environment variables on the output connector definition |
| connectorsGlobal.envFromSecrets | object | `{}` | Secrets from variables |
| connectorsGlobal.volumeMounts | list | `[]` | Additional volumeMounts on the output connector Deployment definition |
| connectorsGlobal.volumes | list | `[]` | Additional volumes on the output connector Deployment definition |
| elasticsearch | object | `{"clusterName":"elastic","coordinating":{"replicaCount":0},"data":{"persistence":{"enabled":false},"replicaCount":1},"enabled":true,"extraEnvVars":[{"name":"ES_JAVA_OPTS","value":"-Xms512M -Xmx512M"}],"ingest":{"enabled":false},"master":{"masterOnly":true,"persistence":{"enabled":false},"replicaCount":1},"sysctlImage":{"enabled":false}}` | ElasticSearch subchart deployment </br> Ref: https://github.com/bitnami/charts/blob/main/bitnami/elasticsearch/values.yaml |
| elasticsearch.enabled | bool | `true` | Enable or disable ElasticSearch subchart |
| env | object | `{"APP__ADMIN__EMAIL":"admin@opencti.io","APP__ADMIN__PASSWORD":"ChangeMe","APP__ADMIN__TOKEN":"ChangeMe","APP__BASE_PATH":"/","APP__GRAPHQL__PLAYGROUND__ENABLED":false,"APP__GRAPHQL__PLAYGROUND__FORCE_DISABLED_INTROSPECTION":false,"APP__HEALTH_ACCESS_KEY":"ChangeMe","APP__TELEMETRY__METRICS__ENABLED":true,"ELASTICSEARCH__URL":"http://release-name-elasticsearch:9200","MINIO__ENDPOINT":"release-name-minio:9000","RABBITMQ__HOSTNAME":"release-name-rabbitmq","RABBITMQ__PASSWORD":"ChangeMe","RABBITMQ__PORT":5672,"RABBITMQ__PORT_MANAGEMENT":15672,"RABBITMQ__USERNAME":"user","REDIS__HOSTNAME":"release-name-redis-master","REDIS__MODE":"single","REDIS__PORT":6379}` | Environment variables to configure application </br> Ref: https://docs.openbas.io/latest/deployment/configuration/#platform |
| envFromSecrets | object | `{}` | Secrets from variables |
| fullnameOverride | string | `""` | String to fully override opencti.fullname template |
| global | object | `{"imagePullSecrets":[],"imageRegistry":""}` | Global section contains configuration options that are applied to all services |
| global.imagePullSecrets | list | `[]` | Specifies the secrets to use for pulling images from private registries Leave empty if no secrets are required E.g. imagePullSecrets:   - name: myRegistryKeySecretName |
| global.imageRegistry | string | `""` | Specifies the registry to pull images from. Leave empty for the default registry |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"opencti/platform","tag":""}` | Image registry configuration for the base service |
| image.pullPolicy | string | `"IfNotPresent"` | Pull policy for the image |
| image.repository | string | `"opencti/platform"` | Repository of the image |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion |
| imagePullSecrets | list | `[]` | Global Docker registry secret names as an array |
| ingress | object | `{"annotations":{},"className":"","enabled":false,"hosts":[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}],"tls":[]}` | Ingress configuration to expose app </br> Ref: https://kubernetes.io/docs/concepts/services-networking/ingress/ |
| lifecycle | object | `{}` | Configure lifecycle hooks </br> Ref: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/ </br> Ref: https://learnk8s.io/graceful-shutdown |
| livenessProbe | object | `{"enabled":true,"failureThreshold":3,"initialDelaySeconds":180,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":5}` | Configure liveness checker </br> Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-startup-probes |
| livenessProbeCustom | object | `{}` | Custom livenessProbe |
| minio | object | `{"auth":{"rootPassword":"ChangeMe","rootUser":"ChangeMe"},"enabled":true,"mode":"standalone","persistence":{"enabled":false}}` | MinIO subchart deployment </br> Ref: https://github.com/bitnami/charts/blob/main/bitnami/minio/values.yaml |
| minio.enabled | bool | `true` | Enable or disable MinIO subchart |
| nameOverride | string | `""` | String to partially override opencti.fullname template (will maintain the release name) |
| networkPolicy | object | `{"egress":[],"enabled":false,"ingress":[],"policyTypes":[]}` | NetworkPolicy configuration </br> Ref: https://kubernetes.io/docs/concepts/services-networking/network-policies/ |
| networkPolicy.enabled | bool | `false` | Enable or disable NetworkPolicy |
| networkPolicy.policyTypes | list | `[]` | Policy types |
| nodeSelector | object | `{}` | Node labels for pod assignment </br> Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector |
| opensearch | object | `{"enabled":false,"opensearchJavaOpts":"-Xmx512M -Xms512M","persistence":{"enabled":false},"singleNode":true}` | OpenSearch subchart deployment </br> Ref: https://github.com/opensearch-project/helm-charts/blob/opensearch-2.16.1/charts/opensearch/values.yaml |
| opensearch.enabled | bool | `false` | Enable or disable OpenSearch subchart |
| podAnnotations | object | `{}` | Configure annotations on Pods |
| podDisruptionBudget | object | `{"enabled":false,"maxUnavailable":1,"minAvailable":null}` | Pod Disruption Budget </br> Ref: https://kubernetes.io/docs/reference/kubernetes-api/policy-resources/pod-disruption-budget-v1/ |
| podLabels | object | `{}` | Configure labels on Pods |
| podSecurityContext | object | `{}` | Defines privilege and access control settings for a Pod </br> Ref: https://kubernetes.io/docs/concepts/security/pod-security-standards/ </br> Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| rabbitmq | object | `{"auth":{"erlangCookie":"ChangeMe","password":"ChangeMe","username":"user"},"clustering":{"enabled":false},"enabled":true,"persistence":{"enabled":false},"replicaCount":1}` | RabbitMQ subchart deployment </br> Ref: https://github.com/bitnami/charts/blob/main/bitnami/rabbitmq/values.yaml |
| rabbitmq.enabled | bool | `true` | Enable or disable RabbitMQ subchart |
| readinessProbe | object | `{"enabled":true,"failureThreshold":3,"initialDelaySeconds":10,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Configure readinessProbe checker </br> Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-startup-probes |
| readinessProbeCustom | object | `{}` | Custom readinessProbe |
| readyChecker | object | `{"enabled":true,"pullPolicy":"IfNotPresent","repository":"busybox","retries":30,"services":[{"name":"elasticsearch","port":9200},{"name":"minio","port":9000},{"name":"rabbitmq","port":5672},{"name":"redis-master","port":6379}],"tag":"latest","timeout":5}` | Enable or disable ready-checker  |
| readyChecker.enabled | bool | `true` | Enable or disable ready-checker |
| readyChecker.pullPolicy | string | `"IfNotPresent"` | Pull policy for the image |
| readyChecker.repository | string | `"busybox"` | Repository of the image |
| readyChecker.retries | int | `30` | Number of retries before giving up |
| readyChecker.services | list | `[{"name":"elasticsearch","port":9200},{"name":"minio","port":9000},{"name":"rabbitmq","port":5672},{"name":"redis-master","port":6379}]` | List services |
| readyChecker.tag | string | `"latest"` | Overrides the image tag |
| readyChecker.timeout | int | `5` | Timeout for each check |
| redis | object | `{"architecture":"standalone","auth":{"enabled":false},"enabled":true,"master":{"count":1,"persistence":{"enabled":false}},"replica":{"persistence":{"enabled":false},"replicaCount":1}}` | Redis subchart deployment </br> Ref: https://github.com/bitnami/charts/blob/main/bitnami/redis/values.yaml |
| redis.enabled | bool | `true` | Enable or disable Redis subchart |
| replicaCount | int | `1` | Number of replicas for the service |
| resources | object | `{}` | The resources limits and requested </br> Ref: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ |
| secrets | object | `{}` | Secrets values to create credentials and reference by envFromSecrets Generate Secret with following name: `<release-name>-credentials` |
| securityContext | object | `{}` | Defines privilege and access control settings for a Container </br> Ref: https://kubernetes.io/docs/concepts/security/pod-security-standards/ </br> Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| service | object | `{"port":80,"targetPort":4000,"type":"ClusterIP"}` | Kubernetes service to expose Pod </br> Ref: https://kubernetes.io/docs/concepts/services-networking/service/ |
| service.port | int | `80` | Kubernetes Service port |
| service.targetPort | int | `4000` | Pod expose port |
| service.type | string | `"ClusterIP"` | Kubernetes Service type. Allowed values: NodePort, LoadBalancer or ClusterIP |
| serviceAccount | object | `{"annotations":{},"automountServiceAccountToken":false,"create":true,"name":""}` | Enable creation of ServiceAccount |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automountServiceAccountToken | bool | `false` | Specifies if you don't want the kubelet to automatically mount a ServiceAccount's API credentials |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | Name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| serviceMonitor | object | `{"enabled":false,"interval":"30s","metricRelabelings":[],"relabelings":[],"scrapeTimeout":"10s"}` | Enable ServiceMonitor to get metrics </br> Ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#servicemonitor |
| serviceMonitor.enabled | bool | `false` | Enable or disable |
| startupProbe | object | `{"enabled":true,"failureThreshold":30,"initialDelaySeconds":180,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":5}` | Configure startupProbe checker </br> Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-startup-probes |
| startupProbeCustom | object | `{}` | Custom startupProbe |
| terminationGracePeriodSeconds | int | `30` | Configure Pod termination grace period </br> Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#pod-termination |
| testConnection | bool | `false` | Enable or disable test connection |
| tolerations | list | `[]` | Tolerations for pod assignment </br> Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ |
| topologySpreadConstraints | list | `[]` | Control how Pods are spread across your cluster </br> Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/#example-multiple-topologyspreadconstraints |
| volumeMounts | list | `[]` | Additional volumeMounts on the output Deployment definition |
| volumes | list | `[]` | Additional volumes on the output Deployment definition |
| worker | object | `{"affinity":{},"autoscaling":{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80},"enabled":true,"env":{"WORKER_LOG_LEVEL":"info","WORKER_TELEMETRY_ENABLED":true},"envFromSecrets":{},"image":{"pullPolicy":"IfNotPresent","repository":"opencti/worker","tag":""},"lifecycle":{},"networkPolicy":{"egress":[],"enabled":false,"ingress":[],"policyTypes":[]},"nodeSelector":{},"podDisruptionBudget":{"enabled":false,"maxUnavailable":1,"minAvailable":null},"readyChecker":{"enabled":true,"pullPolicy":"IfNotPresent","repository":"busybox","retries":30,"tag":"latest","timeout":5},"replicaCount":1,"resources":{},"serviceMonitor":{"enabled":false,"interval":"30s","metricRelabelings":[],"relabelings":[],"scrapeTimeout":"10s"},"terminationGracePeriodSeconds":30,"tolerations":[],"topologySpreadConstraints":[],"volumeMounts":[],"volumes":[]}` | OpenCTI worker deployment configuration </br> Ref: https://docs.opencti.io/latest/deployment/overview/#workers |
| worker.affinity | object | `{}` | Affinity for pod assignment </br> Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity |
| worker.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Autoscaling with CPU or memory utilization percentage </br> Ref: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/ |
| worker.enabled | bool | `true` | Enable or disable worker |
| worker.env | object | `{"WORKER_LOG_LEVEL":"info","WORKER_TELEMETRY_ENABLED":true}` | Environment variables to configure application </br> Ref: https://docs.opencti.io/latest/deployment/configuration/#platform |
| worker.envFromSecrets | object | `{}` | Secrets from variables |
| worker.image | object | `{"pullPolicy":"IfNotPresent","repository":"opencti/worker","tag":""}` | Image registry configuration for the base service |
| worker.image.pullPolicy | string | `"IfNotPresent"` | Pull policy for the image |
| worker.image.repository | string | `"opencti/worker"` | Repository of the image |
| worker.image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion |
| worker.lifecycle | object | `{}` | Configure lifecycle hooks </br> Ref: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/ </br> Ref: https://learnk8s.io/graceful-shutdown |
| worker.networkPolicy | object | `{"egress":[],"enabled":false,"ingress":[],"policyTypes":[]}` | NetworkPolicy configuration </br> Ref: https://kubernetes.io/docs/concepts/services-networking/network-policies/ |
| worker.networkPolicy.enabled | bool | `false` | Enable or disable NetworkPolicy |
| worker.networkPolicy.policyTypes | list | `[]` | Policy types |
| worker.nodeSelector | object | `{}` | Node labels for pod assignment </br> Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector |
| worker.podDisruptionBudget | object | `{"enabled":false,"maxUnavailable":1,"minAvailable":null}` | Pod Disruption Budget </br> Ref: https://kubernetes.io/docs/reference/kubernetes-api/policy-resources/pod-disruption-budget-v1/ |
| worker.readyChecker | object | `{"enabled":true,"pullPolicy":"IfNotPresent","repository":"busybox","retries":30,"tag":"latest","timeout":5}` | Enable or disable ready-checker waiting server is ready |
| worker.readyChecker.enabled | bool | `true` | Enable or disable ready-checker |
| worker.readyChecker.pullPolicy | string | `"IfNotPresent"` | Pull policy for the image |
| worker.readyChecker.repository | string | `"busybox"` | Repository of the image |
| worker.readyChecker.retries | int | `30` | Number of retries before giving up |
| worker.readyChecker.tag | string | `"latest"` | Overrides the image tag |
| worker.readyChecker.timeout | int | `5` | Timeout for each check |
| worker.replicaCount | int | `1` | Number of replicas for the service |
| worker.resources | object | `{}` | The resources limits and requested </br> Ref: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ |
| worker.serviceMonitor | object | `{"enabled":false,"interval":"30s","metricRelabelings":[],"relabelings":[],"scrapeTimeout":"10s"}` | Enable ServiceMonitor to get metrics </br> Ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#servicemonitor |
| worker.serviceMonitor.enabled | bool | `false` | Enable or disable |
| worker.terminationGracePeriodSeconds | int | `30` | Configure Pod termination grace period </br> Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#pod-termination |
| worker.tolerations | list | `[]` | Tolerations for pod assignment </br> Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ |
| worker.topologySpreadConstraints | list | `[]` | Control how Pods are spread across your cluster </br> Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/#example-multiple-topologyspreadconstraints |
| worker.volumeMounts | list | `[]` | Additional volumeMounts on the output Deployment definition |
| worker.volumes | list | `[]` | Additional volumes on the output Deployment definition |
