#!/usr/bin/env bash
#
# Pipe for integrating Bitbucket with Debricked. Automatically analyse your latest commits and pull requests for known vulnerabilities.
#

REPOSITORY="${BITBUCKET_REPO_OWNER}/${BITBUCKET_REPO_SLUG}"
COMMIT=${BITBUCKET_COMMIT}
BRANCH=${BITBUCKET_BRANCH}
REPOSITORY_URL=${BITBUCKET_GIT_HTTP_ORIGIN}
INTEGRATION_NAME=bitbucket
source "$(dirname "$0")/common.sh"
