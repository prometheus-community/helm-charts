---
name: Bug report
about: Create a report to help us improve
title: '[name of the chart e.g. prometheus-kube-stack] issue title'
labels: 'bug'
assignees: ''

---

<!-- Thanks for filing an issue!
Before hitting the button, please answer these questions.
It's helpful to search the existing GitHub issues first.
It's likely that another user has already reported the issue you're facing, or it's a known issue that we're already aware of.

Fill in as much of the template below as you can.
The more information we have the better we can help you.

Be ready for followup questions, and please respond in a timely manner.
If we can't reproduce a bug or think a feature already exists, we might close your issue.
If we're wrong, PLEASE feel free to reopen it and explain why.
-->

**Describe the bug**
A clear and concise description of what the bug is.

**Version of Helm and Kubernetes**:

Helm Version:

```console
$ helm version
please put the output of it here
```

Kubernetes Version:

```console
$ kubectl version
please put the output of it here
```

**Which chart**:

**Which version of the chart**:

**What happened**:

**What you expected to happen**:

**How to reproduce it** (as minimally and precisely as possible):
**Changed values of values.yaml** (only put values which differ from the defaults):

values.yaml

```console
key: value
```

**The helm command that you execute and failing/misfunctioning**:

For example:

```console
helm install my-release prometheus-community/name-of-chart --version version --values values.yaml
```

**Helm values set after installation/upgrade:**

```console
helm get values my-release
```

**Anything else we need to know**:
