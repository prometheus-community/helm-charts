---
name: helm-chart-test
description: Plan, write, and validate helm-unittest tests for a chart. Discovers chart structure, maps coverage gaps, and applies repository helm-unittest conventions.
user_invocable: true
---

# /helm-chart-test [chart] [component]

Use this skill whenever the user asks to add, expand, fix, or review helm-unittest coverage for a chart, or when a chart feature change needs matching rendered-manifest tests.

## Argument Handling

**During feature implementation**, infer the chart and component from the files being changed or from the requested feature. Add or update focused tests for the affected rendered behavior without pausing for broad coverage analysis or scoping questions, unless the requested behavior is ambiguous.

**If no arguments are provided for a standalone test task**, ask the user which chart they want to work on, then proceed as if they provided just the chart name.

**If only `<chart>` is provided for a standalone coverage audit**, run the full discovery and coverage analysis below before asking any questions.

**If `<chart> <component>` is provided for a standalone test task**, inspect that component and choose the relevant existing or new test files. Ask scoping questions only when the requested coverage depth or target templates cannot be inferred.

## Feature Implementation Mode

When this skill is used as part of implementing a chart feature, do not stop after planning or ask the user to choose a component. Instead:

1. Identify the affected chart from `charts/<chart>/...`.
2. Identify affected templates, helpers, and values from the feature diff or requested change.
3. Read existing nearby tests and mirror their style.
4. Add or update focused tests for the new or changed rendered behavior.
5. Cover important enabled/disabled branches, value propagation, selectors, labels, annotations, containers, volumes, and service wiring touched by the feature.
6. Run the relevant `make helm-unittest HELM_CHART=<chart-name>` command.

Ask the user only when there are multiple plausible feature semantics or when the chart/component cannot be determined from local context.

## Discovery and Coverage Analysis

Work through these steps silently. Produce a single structured report at the end.

### 1. Understand the Chart Structure

- Read `charts/<chart>/Chart.yaml` and note the chart type, version, kubeVersion, and dependencies.
- Read the top level of `charts/<chart>/values.yaml` to understand major configuration axes, deployment modes, and component enable flags.
- List `charts/<chart>/templates/**`.
- Identify component groups. Subdirectories under `templates/` are natural groups. If the chart has flat templates, treat the whole chart as one component.
- Read `_helpers.tpl` and any other `_*.tpl` files before testing templates that call helpers.

### 2. Map Existing Test Coverage

- List `charts/<chart>/tests/**`.
- For each component group, count:
  - renderable templates, excluding `_*.tpl` helper/partial files
  - corresponding test files in `charts/<chart>/tests/<component>/`
- Check whether existing tests exercise the relevant branches, not just whether a file exists.

### 3. Assess Complexity

Determine whether the chart is **simple** or **complex**.

- **Simple**: flat templates, no deployment modes, fewer than 10 renderable templates.
- **Complex**: subdirectories, deployment modes, major conditional rendering, or more than 10 renderable templates.

For a simple chart, present a single coverage table and recommend whether to proceed with the whole chart at once.

For a complex chart, group templates into logical work units and recommend a starting component.

### 4. Present the Coverage Report

Use this format:

```md
## <chart> - Test Coverage Analysis

| Component | Renderable templates | Test files | Coverage |
|---|---:|---:|---|
| core / root-level | N | N | None / Partial / Good |
| gateway | N | N | None / Partial / Good |
| ingester | N | N | None / Partial / Good |

### Notes
- <important observations about deployment modes, required values, lookup usage, or test complexity>

### Suggested starting point
<recommend the lowest-risk, highest-value component and explain why>

Recommended next test target: <component or whole chart>
```

For standalone coverage audits, wait for the user to choose a component before writing tests. For feature implementation, proceed with focused tests for the component touched by the feature.

## Scoping Questions

For standalone test-expansion tasks where scope cannot be inferred, ask:

1. Scope within the component: all templates, or specific templates?
2. Existing tests: extend partial tests, or add new test files alongside them?
3. Coverage depth: happy path only, or full branch coverage for every significant `if` / `with` / `range`?
4. Known gotchas: deployment modes, required values, lookup behavior, subchart values, or compatibility constraints?

After the user answers, summarize the agreed scope in one short paragraph, then begin writing tests. Skip these questions when implementing a specific feature and the affected behavior is clear from the request or diff.

## helm-unittest Overview

Tests are YAML files in `charts/<chart-name>/tests/` that validate rendered Kubernetes manifests. Each test renders templates with specified values and asserts on the output.

Each `tests[].it` case renders independently with that case's value inputs. Keep tests focused and deterministic: one behavior per test, explicit value overrides, and scoped assertions.

### Test File Structure

```yaml
# $schema: https://raw.githubusercontent.com/helm-unittest/helm-unittest/refs/heads/main/schema/helm-testsuite.json
suite: <descriptive suite name>
values:
  - ../ci/<values-file>.yaml
set:
  key.nested: value
templates:
  - templates/<path-to-template>.yaml
tests:
  - it: <test case description>
    values:
      - ./values/<scenario>.yaml
    set:
      key.nested: value
    documentSelector:
      path: metadata.name
      value: RELEASE-NAME-myapp
    asserts:
      - isKind:
          of: Deployment
      - equal:
          path: metadata.name
          value: RELEASE-NAME-myapp
      - contains:
          path: spec.template.spec.containers[0].env
          content:
            name: MY_VAR
            value: my-value
```

### Scope, Precedence, and Targeting

- Value precedence: chart `values.yaml` < suite `values` < suite `set` < test `values` < test `set`.
- Template scope precedence: suite `templates` can be narrowed by test `template` / `templates`, then by assertion-level `template`.
- Document targeting precedence: assertion `documentSelector` / `documentIndex` overrides test-level selector/index.
- Use `documentSelector` for multi-document templates instead of brittle numeric `documentIndex` when possible.
- `hasDocuments` ignores selectors by default; set `filterAware: true` to count only selector/index-filtered documents.

### Suite and Test Options

- `release`: exercise behavior that depends on `.Release` (`name`, `namespace`, `revision`, `upgrade`).
- `capabilities`: pin Kubernetes versions/APIs for branches guarded by `.Capabilities.*`.
- `chart`: override `.Chart.version` / `.Chart.appVersion` when template output depends on them.
- `excludeTemplates`: narrow broad template globs to avoid unrelated documents in a suite.
- `skip`: only for temporary or unreleased behavior; prefer active assertions over skipped tests.
- `postRenderer`: use only when chart behavior explicitly depends on post-render transforms.

## Testing `lookup` with `kubernetesProvider`

Use `kubernetesProvider` whenever templates call `lookup`; without it, `lookup` returns empty and branch coverage is incomplete.

- Register API kinds in `scheme` using `"<group>/<version>/<Kind>"` or `"v1/<Kind>"` for core APIs.
- Each scheme entry must define `gvr` (`group` optional for core APIs, plus `version`, `resource`) and `namespaced`.
- Provide fixture resources in `objects`.
- Test-level `kubernetesProvider.objects` can add scenario-specific fixtures without rewriting suite-wide defaults.

```yaml
templates:
  - templates/lookup.yaml
kubernetesProvider:
  scheme:
    "v1/Namespace":
      gvr:
        version: "v1"
        resource: "namespaces"
      namespaced: false
    "v1/Pod":
      gvr:
        version: "v1"
        resource: "pods"
      namespaced: true
    "networking.k8s.io/v1/Ingress":
      gvr:
        group: "networking.k8s.io"
        version: "v1"
        resource: "ingresses"
      namespaced: true
  objects:
    - kind: Pod
      apiVersion: v1
      metadata:
        name: exists
        namespace: default
tests:
  - it: should find existing pod through lookup
    asserts:
      - isNotNullOrEmpty:
          path: pod_exists
      - equal:
          path: pod_exists.metadata.name
          value: exists
  - it: should find test-level object through lookup
    kubernetesProvider:
      objects:
        - kind: Pod
          apiVersion: v1
          metadata:
            name: not-exists
            namespace: default
    asserts:
      - isNotNullOrEmpty:
          path: pod_not_exists
      - equal:
          path: pod_not_exists.metadata.name
          value: not-exists
```

## Assertion Guidance

| Assertion | Purpose |
|---|---|
| `equal` | Exact match at JSON path |
| `notEqual` | Value differs from expected |
| `matchRegex` | Regular expression match on string value |
| `exists` | Path exists in rendered output |
| `notExists` | Path is absent from rendered output |
| `isEmpty` / `isNotEmpty` | Path is empty or not empty |
| `isNullOrEmpty` / `isNotNullOrEmpty` | Path is null/empty or present with content |
| `isKind` | Kubernetes resource kind check |
| `isAPIVersion` | API version check |
| `contains` | Array/map contains entry |
| `notContains` | Array/map does not contain entry |
| `hasDocuments` | Number of YAML documents rendered |
| `matchSnapshot` | Snapshot testing |
| `failedTemplate` | Template should fail to render |
| `notFailedTemplate` | Template should render successfully |
| `isSubset` | Rendered output is a superset of expected |
| `lengthEqual` | Array/map length equals expected count |

Use antonym assertions (`notEqual`, `notContains`, etc.) instead of relying on `not: true` unless that is clearer.

Prefer `equal`, `contains`, and specific negative assertions over broad `exists` checks. Specific assertions catch regressions.

### Assertion Scoping Patterns

```yaml
  - it: targets a single Deployment by name
    templates:
      - templates/deployment.yaml
      - templates/image-renderer-deployment.yaml
    asserts:
      - equal:
          path: spec.replicas
          value: 1
        documentSelector:
          path: metadata.name
          value: RELEASE-NAME-grafana
```

```yaml
  - it: counts only selected docs
    template: templates/extra-manifests.yaml
    documentSelector:
      path: kind
      value: ConfigMap
      matchMany: true
    asserts:
      - hasDocuments:
          count: 2
          filterAware: true
```

### Multi-Template Safety

If a suite includes workload templates plus `config.yaml`, set `template` on every assertion unless the test intentionally targets all templates.

Put `template` at the assertion root, not inside assertion parameters.

Wrong:

```yaml
      - notContains:
          template: backend/statefulset.yaml
          path: spec.template.spec.containers
          content:
            name: loki-sc-rules
```

Correct:

```yaml
      - template: backend/statefulset.yaml
        notContains:
          path: spec.template.spec.containers
          content:
            name: loki-sc-rules
```

### Path and jsonPath Guidance

- Prefer precise paths over broad existence checks.
- When map keys contain dots or slashes, use jsonPath bracket syntax.
- Keep escaping consistent to avoid false negatives.

```yaml
  - equal:
      path: metadata.annotations["kubernetes.io/ingress.class"]
      value: nginx
```

### Conditional Rendering Tests

```yaml
  - it: should not render when disabled
    set:
      component.enabled: false
    asserts:
      - hasDocuments:
          count: 0
```

### Testing with Release Values

```yaml
  - it: should use release name in labels
    release:
      name: my-release
      namespace: my-namespace
    asserts:
      - equal:
          path: metadata.namespace
          value: my-namespace
```

## Test File Organization

Mirror the template directory structure:

```text
charts/<chart>/tests/
  deployment_test.yaml
  service_test.yaml
  ingester/
    statefulset_test.yaml
  compactor/
    deployment_test.yaml
```

Test filenames must end with `.yaml`. This repository configures helm-unittest with `--file 'tests/**/*.yaml'`, so any `.yaml` filename is valid. `<template>_test.yaml` is preferred.

## Writing Workflow

1. Read the template being tested. Understand every conditional, value reference, helper call, and document emitted.
2. Read `_helpers.tpl` and any other helper partials used by the template.
3. Read `values.yaml` to understand defaults and the full value schema.
4. Map render targets: determine whether the template emits zero, one, or many documents and which selector is stable.
5. Write tests for default rendering, significant conditional branches, selector behavior, multi-template scoping, and edge cases.
6. Run the tests.
7. Fix failures by adjusting assertions to match actual rendered output.
8. Repeat until the test file passes.

## Running Tests

Run all charts:

```bash
make helm-unittest
```

Run tests for one chart:

```bash
make helm-unittest HELM_CHART=<chart-name>
```

Run one test file:

```bash
make helm-unittest HELM_CHART=<chart-name> HELM_UNITTEST_FILE='tests/<subdir>/<file>_test.yaml'
```

## Rules

- Only create or edit `.yaml` files under `charts/*/tests/` when this skill is being used specifically to write tests.
- Do not modify templates, `values.yaml`, `Chart.yaml`, or non-test files as part of a test-writing task unless the user explicitly expands the scope.
- Never run destructive shell commands.
- Use `RELEASE-NAME` as the default release name in assertions.
- Always set deployment-mode-style flags explicitly. Do not rely on defaults when a chart has conditional rendering modes.
- When a template has subchart dependencies, use `set` to provide required subchart values.
- Always run relevant helm-unittest commands after writing tests.
- If a test run reveals the template does not render with default values, inspect `values.yaml` and adjust the test setup.
- Prefer `documentSelector` over hardcoded `documentIndex` for templates that can reorder output.
- Use `hasDocuments.filterAware: true` when asserting counts under selector/index filtering.
- Use `template` / `templates` at test or assertion level to prevent cross-template assertion bleed.
- For negative paths, assert absence with `notExists` or `notContains`.
