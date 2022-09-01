# Changelog
Note: version releases in the 0.x.y range may introduce breaking changes.

## 2.3.1

- patch: Add Travis CI pipe script

## 2.3.0

- minor: Add githubActions as integration name

## 2.2.0

- minor: Add Argo Workflows script

## 2.1.1

- patch: Fix setting commit author in Azure DevOps

## 2.1.0

- minor: Add BuildKite pipe script

## 2.0.0

- major: Upgrade Debricked-cli to version 10. Snippet analysis is now disabled by default, it can be enabled by setting SNIPPET_ANALYSIS to true

## 1.5.0

- minor: Add support for disabling conditional skip scan.

## 1.4.6

- patch: Recommend source code less scans instead of uploading all files.
- patch: Update to latest version of debricked-cli.

## 1.4.5

- patch: Update to latest version of debricked-cli.

## 1.4.4

- patch: Add support for getting configured default branch in GitLab

## 1.4.3

- patch: Refactor script to use the new Automations name rather than policy engine

## 1.4.2

- patch: Make scans more resilient by updating to latest version of debricked-cli.

## 1.4.1

- patch: Update to latest version of debricked-cli.

## 1.4.0

- minor: Add support for Automations Webhook.

## 1.3.1

- patch: Update debricked-cli to 7.2.1 in order to pick up hidden files

## 1.3.0

- minor: Add support for access tokens and show Automations output, if any

## 1.2.5

- patch: Add support for latest debricked-cli

## 1.2.4

- patch: Upgrade debricked-cli to 6.0.3

## 1.2.3

- patch: Fallback to git log if author is not available from GitLab

## 1.2.2

- patch: Add support for sending commit author.

## 1.2.1

- patch: Parse repository url smarter, and allow override

## 1.2.0

- minor: Add support for CircleCI

## 1.1.7

- patch: Improved parsing of some options

## 1.1.6

- patch: Modernised pipe config

## 1.1.5

- patch: Adds support for conditional scan - when scan queues are exceptional long the command will return immediately as to not block for a very long time

## 1.1.4

- patch: Update debricked-cli

## 1.1.3

- patch: Add support for policy engine.
- patch: Minor fixes to policy engine support

## 1.1.2

- patch: Use proper organization name for Azure DevOps

## 1.1.1

- patch: Fix scanning for repo names containing spaces

## 1.1.0

- minor: Upgrade to debricked-cli 5.0.0, add setting to disable snippet scan.

## 1.0.3

- patch: Pass pipeline checks with warning when vulnerabilities discovered

## 1.0.2

- patch: Fix branch and tag name detection for Github Action.

## 1.0.1

- patch: New debricked-cli version, supports uploading adjacent dependency tree files.

## 1.0.0

- major: Upgrade required for scans to continue to work! Support dependency files with wildcards, such as *.csproj and *.bzl and more.

## 0.6.0

- minor: Add support for Github Actions.
- patch: Fix Gitlab integration running scan twice for each push in some occasions.

## 0.5.3

- patch: Added support for 'upload all files' option.

## 0.5.2

- patch: Bumped version number due to new version of debricked/cli 3.0.3

## 0.5.1

- patch: Bumped version number due to new version of debricked/cli 3.0.2

## 0.5.0

- minor: Added support for link to dependency file

## 0.4.2

- patch: Added support for Azure DevOps. No changes to existing integrations.

## 0.4.1

- patch: Bumped version number due to new version of debricked/cli

## 0.4.0

- minor: Add support for branches and an option to skip the scan, just uploading dependency files

## 0.3.0

- minor: Updated debricked/cli to a version supporting unaffected vulnerabilities

## 0.2.5

- patch: Made compatible with latest version of debricked/cli

## 0.2.4

- patch: Bumped version number due to new version of debricked/cli

## 0.2.3

- patch: Bumped version number due to new version of debricked/cli

## 0.2.2

- patch: Only run scan once in GitLab CI integration

## 0.2.1

- patch: Minor fixes to GitLab CI integration

## 0.2.0

- minor: Added support for GitLab CI

## 0.1.1

- patch: Changed pipe icon to a square logo

## 0.1.0

- minor: Initial release
