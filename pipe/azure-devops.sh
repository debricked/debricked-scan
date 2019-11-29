#!/usr/bin/env bash
#
# Step for integrating Azure DevOps with Debricked. Automatically analyse your latest commits and pull requests for known vulnerabilities.
#

REPOSITORY="${Build.Repository.Name}"
COMMIT=${Build.SourceVersion}
BRANCH=${Build.SourceBranchName}
BASE_DIRECTORY=${BASE_DIRECTORY:=Build.SourcesDirectory}

source "$(dirname "$0")/common.sh"
