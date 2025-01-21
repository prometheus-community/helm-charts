#!/usr/bin/env bash

# Make sure sort works predictably.
export LC_ALL=C

cat <<EOF
# See https://github.com/prometheus-community/helm-charts/issues/12
# https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/about-code-owners
# https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/about-code-owners#codeowners-syntax

# The repo admins team will be the default owners for everything in the repo.
# Unless a later match takes precedence, they will be requested for review when someone opens a pull request.
* @prometheus-community/helm-charts-admins

/.github/workflows/ @prometheus-community/helm-charts-admins @GMartinez-Sisti
/renovate.json @prometheus-community/helm-charts-admins @GMartinez-Sisti

EOF

yq_script='"/charts/" + .name + "/ " + ([.maintainers[].url | sub("https://github.com/", "@")] | sort | join(" "))'

yq e "${yq_script}" charts/*/Chart.yaml |
  sort -t '/' -k 3
