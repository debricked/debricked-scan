#!/usr/bin/env bash

USERNAME="${DEBRICKED_USERNAME}"
PASSWORD="${DEBRICKED_PASSWORD}"
REPOSITORY="${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}"
COMMIT="${CIRCLE_SHA1}"
BRANCH="${CIRCLE_BRANCH}"
BASE_DIRECTORY=${BASE_DIRECTORY:=""}
INTEGRATION_NAME=circleci
if command -v git &> /dev/null
then
  AUTHOR=$(git log -1 --pretty=%ae)
fi

# the repository url is determined according to the following rules:
# 1. If DEBRICKED_REPOSITORY_URL is set, always use it as the repo url.
# 2. If CIRCLE_REPOSITORY_URL starts with "http(s)://", use it as the repo url.
# 3. If CIRCLE_REPOSITORY_URL is of the form "git@github.com:organisation/reponame.git",
#    rewrite and use "https://github.com/organisation/reponame" as repo url.
# 4. Otherwise, show warning and set repository url to ""
if [ -n "$DEBRICKED_REPOSITORY_URL" ]; then
    REPOSITORY_URL="$DEBRICKED_REPOSITORY_URL"
else
    http_regex="^https?://"
    github_regex="^[^@]+@github.com:([^/]+)/(.+)\.git$"
    if [[ $CIRCLE_REPOSITORY_URL =~ $http_regex ]]; then
        REPOSITORY_URL="$CIRCE_REPOSITORY_URL"
    elif [[ $CIRCLE_REPOSITORY_URL =~ $github_regex ]]; then
        org="${BASH_REMATCH[1]}"
        repo="${BASH_REMATCH[2]}"
        REPOSITORY_URL="https://github.com/${org}/${repo}"
    else
        echo "INFO: Your repository URL could not be found. Set it manually with DEBRICKED_REPOSITORY_URL"
        REPOSITORY_URL=""
    fi
fi

source "$(dirname "$0")/common.sh"
