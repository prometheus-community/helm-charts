#!/usr/bin/env bash

cat <<EOF
# See https://github.com/scottrigby/prometheus-helm-charts/issues/12
# https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/about-code-owners
# https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/about-code-owners#codeowners-syntax

# The repo admins team will be the default owners for everything in the repo.
# Unless a later match takes precedence, they will be requested for review when someone opens a pull request.
* @prometheus-community/helm-charts-admins

EOF

for DIR in $(ls -1 -d ./charts/*)
do
  FILE="$DIR/Chart.yaml"
  DIR=$(echo $DIR | sed 's/^\.//')
  MAINTAINERS=$(yq r $FILE 'maintainers.[*].name'| sed 's/^/@/' | sort)
  echo $DIR/ $MAINTAINERS
done
