#!/usr/bin/env bash
#
# CI script for integrating GitLab CI with Debricked. Automatically analyse your latest commits and pull requests for known vulnerabilities.
#

PRODUCT="${CI_MERGE_REQUEST_PROJECT_PATH}"
RELEASE="${CI_COMMIT_SHA}"

source "$(dirname "$0")/common.sh"
