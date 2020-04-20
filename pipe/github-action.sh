#!/usr/bin/env bash
#
# CI script for integrating Github Actions with Debricked. Automatically analyse your latest commits and pull requests for known vulnerabilities.
#

REPOSITORY="${GITHUB_REPOSITORY}"
COMMIT="${GITHUB_SHA}"
BRANCH="${GITHUB_REF}"
BASE_DIRECTORY=${BASE_DIRECTORY:=""}
REPOSITORY_URL="https://github.com/${GITHUB_REPOSITORY}"
INTEGRATION_NAME=github
SKIP_SCAN=${SKIP_SCAN}
source "$(dirname "$0")/common.sh"
