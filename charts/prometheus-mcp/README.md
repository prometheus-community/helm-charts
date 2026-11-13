# Prometheus MCP Server

This chart deploys the [Prometheus MCP server](https://github.com/prometheus/prometheus-mcp) on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

The Prometheus MCP server exposes a running Prometheus instance (or compatible backend, e.g. Thanos) to LLM clients via the [Model Context Protocol](https://modelcontextprotocol.io/).

An optional prometheus `ServiceMonitor` can be enabled, should you wish to monitor this MCP server with [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator).

## Prerequisites

- Kubernetes 1.25+
- A running Prometheus instance accessible from the cluster

## Usage

The chart is distributed as an [OCI Artifact](https://helm.sh/docs/topics/registries/) as well as via a traditional [Helm Repository](https://helm.sh/docs/topics/chart_repository/).

- OCI Artifact: `oci://ghcr.io/prometheus-community/charts/prometheus-mcp`
- Helm Repository: `https://prometheus-community.github.io/helm-charts` with chart `prometheus-mcp`

The installation instructions use the OCI registry. Refer to the [`helm repo`](https://helm.sh/docs/helm/helm_repo/) command documentation for information on installing charts via the traditional repository.

### Install Chart

```console
helm install [RELEASE_NAME] oci://ghcr.io/prometheus-community/charts/prometheus-mcp \
  --set prometheus.url=http://prometheus:9090
```

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

### Uninstall Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

### Upgrading Chart

```console
helm upgrade [RELEASE_NAME] oci://ghcr.io/prometheus-community/charts/prometheus-mcp --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values oci://ghcr.io/prometheus-community/charts/prometheus-mcp
```

### HTTP client configuration

TLS and authentication towards Prometheus are configured through an
[`http_config`](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#http_config)
block, stored in a Kubernetes Secret since it may contain credentials. Either
inline it or reference an existing Secret:

```yaml
prometheus:
  url: https://prometheus:9090

httpConfig:
  enabled: true
  config:
    basic_auth:
      username: admin
      password: secret
    tls_config:
      ca_file: /var/certs/ca.crt
      insecure_skip_verify: false

extraVolumes:
  - name: certs
    secret:
      secretName: prometheus-tls

extraVolumeMounts:
  - name: certs
    mountPath: /var/certs
    readOnly: true
```

Alternatively, reference a pre-existing Secret whose data key matches
`httpConfig.secretKey` (default `http-config.yaml`). Rotating its contents
needs a pod restart (for example
`kubectl rollout restart deployment -l app.kubernetes.io/instance=<release>`):
the chart adds a rollout checksum only for the Secret it renders itself, and
the server reads the file once at startup.

```console
helm install prometheus-mcp oci://ghcr.io/prometheus-community/charts/prometheus-mcp \
  --set prometheus.url=https://prometheus:9090 \
  --set httpConfig.enabled=true \
  --set httpConfig.existingSecret=my-http-config-secret
```

An `Authorization` header on an MCP request is forwarded to Prometheus (a bare
token with no scheme is sent as `Bearer <token>`) and takes precedence over
`basic_auth` and `authorization` in the config, though not over `oauth2`.
Anything that injects one in front of the listener, such as an auth proxy,
changes which credentials Prometheus sees.

### Ingress

The example narrows the ingress to the MCP endpoint (see the warning below).

```yaml
ingress:
  enabled: true
  ingressClassName: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
  hosts:
    - host: prometheus-mcp.example.com
      paths:
        - path: /mcp
          pathType: Prefix
  tls:
    - secretName: prometheus-mcp-tls
      hosts:
        - prometheus-mcp.example.com
```

### HTTPRoute (Gateway API)

Requires the [Gateway API](https://gateway-api.sigs.k8s.io/) CRDs and a
Gateway to attach to. The route targets the chart's Service; `matches` below
narrows it to the MCP endpoint.

```yaml
route:
  main:
    enabled: true
    parentRefs:
      - name: my-gateway
        namespace: gateway-system
    hostnames:
      - prometheus-mcp.example.com
    matches:
      - path:
          type: PathPrefix
          value: /mcp
```

Some controllers apply a short default request timeout (Envoy Gateway uses
15s), which cuts tool calls that run longer. Set `timeouts` on the route to
raise or disable it (`request: 0s`). It needs Gateway API CRDs from v1.2.0,
renders only for `kind: HTTPRoute`, and does not apply to the redirect rule or
to `additionalRules`.

> **Warning**: the server has no authentication of its own. Anyone who can
> reach `/mcp` queries Prometheus with the credentials from
> [HTTP client configuration](#http-client-configuration), and can run the
> TSDB admin tools when `tsdbAdmin.enabled` is set. Restrict access at the
> network level or put an auth proxy in front of the ingress or route.
>
> The server also serves everything on a single listener, including Go
> pprof debug endpoints under `/debug/pprof/`. An ingress path or route match
> of `/` (the chart default for both) exposes those publicly along with `/mcp`
> and `/metrics`, and a NodePort or LoadBalancer Service publishes every path
> the same way — profile collection is an easy CPU-exhaustion vector and
> heap/goroutine dumps can leak internals. Restrict the ingress paths or route
> `matches` to what you need, as in the examples above. Basic auth on the
> listener from a
> [web config file](https://prometheus.io/docs/prometheus/latest/configuration/https/)
> is not a substitute: it also gates the health and metrics endpoints, so the
> probes, the ServiceMonitor and `helm test` fail, and it changes which
> credentials reach Prometheus (see
> [HTTP client configuration](#http-client-configuration)).

### TLS on the listener

TLS from a web config file applies to the whole listener, so the chart's own
HTTP clients have to follow it: set `scheme: HTTPS` under `httpGet` in the
`startupProbe`, `livenessProbe`, and `readinessProbe`; set
`serviceMonitor.scheme: https` and, unless the certificate is publicly
trusted, `serviceMonitor.tlsConfig`; and expect `helm test` to fail, since its
checks speak plain HTTP.

### Replicas and autoscaling

The server is a stateless proxy in front of Prometheus: the HTTP transport
keeps no MCP sessions, so any replica can answer any request and no session
affinity is needed. Set `replicaCount`, or hand the count to a
HorizontalPodAutoscaler and guard voluntary disruptions with a
PodDisruptionBudget:

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80

podDisruptionBudget:
  maxUnavailable: 1

resources:
  requests:
    cpu: 250m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 256Mi
```

Utilization targets are relative to the container's requests, so the HPA needs
`resources.requests.cpu` to do anything. Keep the target on CPU: the Go runtime
returns memory to the OS lazily, so a memory target tends to scale up and never
back down.

CPU is the resource that matters. A tool call costs a few milliseconds of CPU
for a small query plus roughly a quarter of a millisecond per KB of Prometheus
response, so one replica with a 200m quota sustains a few dozen small calls per
second before latency tails grow; a 1 CPU limit per replica is a comfortable
ceiling. Memory stays around 100 to 160 MiB under load. Startup builds a
search index over the embedded documentation corpus, which costs a few
CPU-seconds, so a new replica under a tight CPU limit takes tens of seconds
to pass its startup probe; keep that in mind when sizing `minReplicas` for
bursty traffic.

### Grafana dashboard

`grafana.dashboards.enabled` ships the upstream dashboard as a ConfigMap for
the Grafana sidecar to pick up. The copy under `dashboards/` is synced from
the upstream repository at the chart's `appVersion` with
`hack/sync_grafana_dashboard.sh`, and `ci/lint.sh` fails when the two differ.
While the release at `appVersion` carries no dashboard file yet, the chart's
copy leads and the check passes with a notice.
