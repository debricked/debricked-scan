#!/usr/bin/env bash
#
# CI script for integrating GitLab CI with Debricked. Automatically analyse your latest commits and pull requests for known vulnerabilities.
#

if [[ ! -f /ci_runned ]] ; then
    PRODUCT="${CI_PROJECT_PATH}"
    RELEASE="${CI_COMMIT_SHA}"
    BRANCH="${CI_COMMIT_REF_NAME}"
    BASE_DIRECTORY=${BASE_DIRECTORY:=$CI_PROJECT_DIR}

    source "$(dirname "$0")/common.sh"
fi

[[ $CI ]] && touch /ci_runned
