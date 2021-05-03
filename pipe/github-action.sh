#!/usr/bin/env bash
#
# CI script for integrating Github Actions with Debricked. Automatically analyse your latest commits and pull requests for known vulnerabilities.
#

# Github gives branches as: refs/heads/master, and tags as refs/tags/v1.1.0.
# Remove prefix refs/{tags,heads} from the name before sending to Debricked.
refonly="${GITHUB_REF#refs/heads/}"
refonly="${refonly#refs/tags/}"

REPOSITORY="${GITHUB_REPOSITORY}"
COMMIT="${GITHUB_SHA}"
BRANCH="${refonly}"
BASE_DIRECTORY=${BASE_DIRECTORY:=""}
REPOSITORY_URL="https://github.com/${GITHUB_REPOSITORY}"
INTEGRATION_NAME=github
SKIP_SCAN=${SKIP_SCAN}
if command -v git &> /dev/null
then
  AUTHOR=$(git log -1 --pretty=%ae)
fi
source "$(dirname "$0")/common.sh"
