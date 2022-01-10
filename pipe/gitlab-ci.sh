#!/usr/bin/env bash
#
# CI script for integrating GitLab CI with Debricked. Automatically analyse your latest commits and pull requests for known vulnerabilities.
#

if [[ ! -f /ci_runned ]] ; then
    REPOSITORY="${CI_PROJECT_PATH}"
    COMMIT="${CI_COMMIT_SHA}"
    BRANCH="${CI_COMMIT_REF_NAME}"
    if [ ! -z "${CI_DEFAULT_BRANCH}" ]; then
      DEFAULT_BRANCH="${CI_DEFAULT_BRANCH}"
    else
      echo -e "You are probably using a version of gitlab before 12.4. This means we can not know what your default branch is. This might impact your experience using Debricked's tools"
    fi
    BASE_DIRECTORY=${BASE_DIRECTORY:=$CI_PROJECT_DIR}
    REPOSITORY_URL=${CI_PROJECT_URL}
    INTEGRATION_NAME=gitlab
    SKIP_SCAN=${SKIP_SCAN}
    if [ -n "${CI_COMMIT_AUTHOR}" ]; then
      AUTHOR="${CI_COMMIT_AUTHOR}"
    elif command -v git &> /dev/null
    then
      AUTHOR=$(git log -1 --pretty=%ae)
    fi

    [[ $CI ]] && touch /ci_runned
    source "$(dirname "$0")/common.sh"
fi
