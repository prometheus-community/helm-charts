# Processes

This document outlines processes and procedures for some common tasks in the charts repository.

## Review Process

One of the Chart maintainers should review the PR.
If everything is fine (passes [Technical Requirements](https://github.com/prometheus-community/helm-charts/blob/main/CONTRIBUTING.md#technical-requirements), etc) then the PR should be [approved](https://docs.github.com/en/free-pro-team@latest/github/collaborating-with-issues-and-pull-requests/approving-a-pull-request-with-required-reviews).
The one who approves the PR should also merge it directly.
In case the reviewer wants someone else to have a look on it,
it should be mentioned as a comment so that it's transparent for everyone.

As a chart maintainer can not approve it's own PRs every chart should have at least two maintainers.
For charts where this is not the case or where none of the other maintainers does a review within two weeks the maintainer who created the PR could request a review from a repository admin instead.

## Adding chart maintainers

Chart maintainers are defined within the chart itself.
So the procedure for adding maintainers is to add them there.
The pull request which does that should also update [CODEOWNERS](./.github/CODEOWNERS) file to that the new maintainer is able to approve pull requests.
One of the existing chart maintainers needs to approve the PR in addition one of the repository admins needs to approve it.
They are then responsible for also granting the new maintainer write permissions to this repository.

## GitHub Settings

As not everyone is able to see which settings are configured for this repository these are also documented here.
Changing settings outlined should only be done once a PR is approved which documents those changes.

### Merge Settings

Only squash merge is allowed in this repository:

> Allow squash merging
> Combine all commits from the head branch into a single commit in the base branch.

"Allow merge commits" and "Allow rebase merging" are disabled to keep the history simple and clean.

### Repository Access

Repository access and permissions are managed via the GitHub teams.

| GitHub Team | Repository Access |
| ----------- | ---- |
| [helm-charts-maintainers](https://github.com/orgs/prometheus-community/teams/helm-charts-maintainers) | Write |
| [helm-charts-admins](https://github.com/orgs/prometheus-community/teams/helm-charts-admins) | Admin |

Chart maintainers are members of [@prometheus-community/helm-charts-maintainers](https://github.com/orgs/prometheus-community/teams/helm-charts-maintainers).
This allows them to manage issues, review PRs etc according to the rules in [CODEOWNERS](./.github/CODEOWNERS).
To request adding a user to [@prometheus-community/helm-charts-maintainers](https://github.com/orgs/prometheus-community/teams/helm-charts-maintainers), ask [@prometheus-community/helm-charts-admins](https://github.com/orgs/prometheus-community/teams/helm-charts-admins) in the corresponding issue or pull request.

Admin permissions allow you to modify repository settings, that's nothing which is needed on a daily basis.
The goals is to limit the number of admins to avoid misconfigurations.
At the same time it makes sense to have more than one admin so that changes from one admin can be reviewed by another one.
At the moment there are three admins.

### Branch Protection Rules

The `main` branch is protected and the following settings are configured:

- Require pull request reviews before merging: 1
  > When enabled, all commits must be made to a non-protected branch and submitted via a pull request with the required number of approving reviews and no changes requested before it can be merged into a branch that matches this rule.

  As many people rely on charts hosted in this repository each PR must be reviewed before it can be merged.
  
  - Dismiss stale pull request approvals when new commits are pushed

    > New reviewable commits pushed to a matching branch will dismiss pull request review approvals.

    This prevents that changes can be made unnoticed to already approved PRs.
    As a consequence of this every change made to an already approved PR will need another approval.

  - Require review from Code Owners

    > Require an approved review in pull requests including files with a designated code owner.

    This repository hosts multiple helm charts with different maintainers.
    This setting helps us to ensure, that every change to a chart needs to be approved by at least one of the maintainers of a that chart.

    As a consequence CODEOWNERS and maintainers of a chart defined in `Chart.yaml` needs to be in sync.

- Require status checks to pass before merging
  > Choose which [status checks](https://docs.github.com/en/free-pro-team@latest/rest/reference/repos#statuses) must pass before branches can be merged into a branch that matches this rule. When enabled, commits must first be pushed to another branch, then merged or pushed directly to a branch that matches this rule after status checks have passed.
  - DCO

    [Developer Certificate of Origin](https://developercertificate.org/) (DCO) check is performed by [DCO GitHub App](https://github.com/apps/dco)

  - Lint Code Base

    Linting is done using [Super-Linter](https://github.com/github/super-linter).
    It is configured in [linter.yaml](.github/workflows/linter.yml)

  - lint-test

    Helm charts are tested using [Chart Testing](https://github.com/helm/chart-testing), which is configured in [lint-test.yaml](.github/workflows/lint-test.yaml).

- Include administrators
  > Enforce all configured restrictions above for administrators.

  To play fair all the settings above are also applied for administrators.

- Force pushes and deletions are disabled

  Force pushes and deletions on the `main` branch should never be done.
