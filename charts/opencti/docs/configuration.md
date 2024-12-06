# Basic installation

See [Customizing the chart before installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with comments:

```console
helm show values opencti/opencti
```

You may also helm show values on this chart's dependencies for additional options.

## Components

Basic installation will deploy the following components:

* OpenCTI server
* OpenCTI worker
* ElasticSearch or OpenSearch
* MinIO
* RabbitMQ
* Redis

### OpenCTI server

Basic config server block to configure:

```yaml
env:
  APP__ADMIN__EMAIL: admin@opencti.io
  APP__ADMIN__PASSWORD: test
  APP__ADMIN__TOKEN: b1976749-8a53-4f49-bf04-cafa2a3458c1
  APP__BASE_PATH: "/"
  APP__SESSION_COOKIE: "true"
  ...
```

Expose service:

```yaml
ingress:
  enabled: true
  hosts:
    - host: demo.mydomain.com
      paths:
        - path: /
          pathType: Prefix
```

### ElasticSearch

> [!IMPORTANT]
> Only you can configure `ElasticSearch` or `OpenSearch` on OpenCTI config.

Server block to configure ElasticSearch:

```yaml
env:
...
  ELASTICSEARCH__ENGINE_SELECTOR: auto
  ELASTICSEARCH__URL: http://<release-name>-elasticsearch:9200
```

Basic config:

```yaml
elasticsearch:
  enabled: true

  sysctlImage:
    enabled: false

  master:
    masterOnly: true
    replicaCount: 1
    persistence:
      enabled: false

  data:
    replicaCount: 1
    persistence:
      enabled: false

  ingest:
    enabled: false

  coordinating:
    replicaCount: 0
```

Configure `JAVA_OPTS` for `elasticsearch.extraEnvVars` block:

```yaml
elasticsearch:
  extraEnvVars:
    - name: ES_JAVA_OPTS
      value: "-Xms512M -Xmx512M"
```

More info. [chart values](https://github.com/bitnami/charts/blob/main/bitnami/elasticsearch/values.yaml)

### OpenSearch

> [!IMPORTANT]
> Only you can configure `ElasticSearch` or `OpenSearch` on OpenCTI config.

Server block to configure OpenSearch:

```yaml
env:
...
  ELASTICSEARCH__ENGINE_SELECTOR: opensearch
  ELASTICSEARCH__URL: http://<release-name>-elasticsearch:9200
```

Basic config:

```yaml
opensearch:
  enabled: true
  opensearchJavaOpts: "-Xmx512M -Xms512M"
  singleNode: true
  securityConfig:
    config:
      data:
        internal_users.yml: |-
          admin:
            hash: "$2a$12$VcCDgh2NDk07JGN0rjGbM.Ad41qVR/YFJcgHp0UGns5JDymv..TOG"
            reserved: true
            backend_roles:
            - "admin"
            description: "Demo admin user"

  persistence:
    enabled: false
```

Move `opensearch.securityConfig.config.data.internal_users.yml` to `secrets` block for `auth`:

```yaml
secrets:
  ELASTICSEARCH__USERNAME: admin
  ELASTICSEARCH__PASSWORD: admin
  - name: internal_users.yml
    value: |-
      _meta:
        type: "internalusers"
        config_version: 2
      admin:
        hash: "$2a$12$VcCDgh2NDk07JGN0rjGbM.Ad41qVR/YFJcgHp0UGns5JDymv..TOG"
        reserved: true
        backend_roles:
        - "admin"
        description: "Demo admin user"
```

Configure `envFromSecrets` for server block:

```yaml
envFromSecrets:
  ELASTICSEARCH__USERNAME:
    name: <release-name>-credentials
    key: ELASTICSEARCH__USERNAME
  ELASTICSEARCH__PASSWORD:
    name: <release-name>-credentials
    key: ELASTICSEARCH__PASSWORD
```

Configure OpenSearch `opensearch.securityConfig.config.data.internal_users.yml` with existing secret:

```yaml
opensearch.securityConfig.internalUsersSecret: <release-name>-credentials
```

More info. [chart values](https://github.com/opensearch-project/helm-charts/blob/main/charts/opensearch/values.yaml)

### MinIO

Server block to configure MinIO:

```yaml
env:
...
  MINIO__ENDPOINT: <release-name>-minio:9000
```

Basic config:

```yaml
minio:
  enabled: true
  mode: standalone
  auth:
    rootUser: ChangeMe
    rootPassword: ChangeMe

  persistence:
    enabled: false
```

Move `minio.auth.rootUser` and `minio.auth.rootPassword` to `secrets` block for `auth`:

```yaml
secrets:
  root-user: MySecretPassword
  root-password: MySecretErlangCookie
```

Configure `envFromSecrets` for server block:

```yaml
envFromSecrets:
  MINIO__ACCESS_KEY:
    name: <release-name>-credentials
    key: root-user
  MINIO__SECRET_KEY:
    name: <release-name>-credentials
    key: root-password
```

Configure Minio `minio.auth` with existing secret:

```yaml
minio.auth.existingSecret: <release-name>-credentials
```

More info. [chart values](https://github.com/bitnami/charts/blob/main/bitnami/minio/values.yaml)

### RabbitMQ

Server block to configure RabbitMQ:

```yaml
env:
...
  RABBITMQ__HOSTNAME: <release-name>-rabbitmq
  RABBITMQ__PORT_MANAGEMENT: 15672
  RABBITMQ__PORT: 5672
  RABBITMQ__USERNAME: user
  RABBITMQ__PASSWORD: ChangeMe
```

Basic config:

```yaml
rabbitmq:
  enabled: true
  replicaCount: 1
  clustering:
    enabled: false

  auth:
    username: user
    password: ChangeMe
    erlangCookie: ChangeMe

  persistence:
    enabled: false
```

Move `rabbitmq.auth.password` and `rabbitmq.auth.erlangCookie` to `secrets` block for `auth`:

```yaml
secrets:
  rabbitmq-password: MySecretPassword
  rabbitmq-erlang-cookie: MySecretErlangCookie
```

Configure `envFromSecrets` for server block:

```yaml
envFromSecrets:
  RABBITMQ__PASSWORD:
    name: <release-name>-credentials
    key: rabbitmq-password
  RABBITMQ__ERLANGCOOKIE:
    name: <release-name>-credentials
    key: rabbitmq-erlang-cookie
```

Configure RabbitMQ `rabbitmq.auth` with existing secret:

```yaml
rabbitmq.auth.existingPasswordSecret: <release-name>-credentials
rabbitmq.auth.existingErlangSecret: <release-name>-credentials
```

More info. [chart values](https://github.com/bitnami/charts/blob/main/bitnami/rabbitmq/values.yaml)

### Redis

Server block to configure Redis:

```yaml
env:
...
  REDIS__HOSTNAME: <release-name>-redis-master
  REDIS__PORT: 6379
  REDIS__MODE: single
```

Basic config:

```yaml
redis:
  enabled: true
  architecture: standalone
  auth:
    enabled: false

  master:
    count: 1
    persistence:
      enabled: false

  replica:
    replicaCount: 1
    persistence:
      enabled: false
```

More info. [chart values](https://github.com/bitnami/charts/blob/main/bitnami/redis/values.yaml)
