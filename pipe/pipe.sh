#!/usr/bin/env bash
#
# Pipe for integrating Bitbucket with Debricked. Automatically analyse your latest commits and pull requests for known vulnerabilities.
#

PRODUCT="${BITBUCKET_REPO_OWNER}/${BITBUCKET_REPO_SLUG}"
RELEASE=${BITBUCKET_COMMIT}

source "$(dirname "$0")/common.sh"
