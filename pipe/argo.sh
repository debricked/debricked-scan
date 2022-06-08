#!/usr/bin/env bash

USERNAME="${DEBRICKED_USERNAME}"
PASSWORD="${DEBRICKED_PASSWORD}"
# the repository is determined according to the following rules:
# 1. If REPOSITORY IS SET, use it.
# 2. If DEBRICKED_GIT_URL starts with "http(s)://" and ends with ".git", use capture group to set REPOSITORY.
# 3. If DEBRICKED_GIT_URL starts with "git@" and ends with ".git", use capture group to set REPOSITORY.
# 4. Set REPOSITORY to DEBRICKED_GIT_URL.
http_name_regex="^https?:\/\/.+\.[a-z0-9]+\/(.+)\.git$"
ssh_name_regex="^.*:[0-9]*\/*(.+)\.git$"
if [ -z "$REPOSITORY" ]; then
  if [[ $DEBRICKED_GIT_URL =~ $http_name_regex ]]; then
      REPOSITORY="${BASH_REMATCH[1]}"
  elif [[ $DEBRICKED_GIT_URL =~ $ssh_name_regex ]]; then
      REPOSITORY="${BASH_REMATCH[1]}"
  else
      REPOSITORY="${DEBRICKED_GIT_URL}"
  fi
fi

INTEGRATION_NAME=argoWorkflows

if command -v git &> /dev/null; then
  git config --global --add safe.directory "$(pwd)"
fi

if [ -z "$COMMIT" ]; then
    if git status &> /dev/null
    then
      COMMIT=$(git log -1 --pretty=%H)
    else
      echo "INFO: Commit could not be found. Set it manually with COMMIT"
      exit 1
    fi
fi
if [ -z "$BRANCH" ]; then
    if git status &> /dev/null
    then
      BRANCH=$(git branch --show-current)
    else
      echo "INFO: Repository branch could not be found. Set it manually with BRANCH"
    fi
fi
if [ -z "$AUTHOR" ]; then
    if git status &> /dev/null
    then
      AUTHOR=$(git log -1 --pretty=%ae)
    else
      echo "INFO: Commit-author could not be found. Set it manually with AUTHOR"
    fi
fi

# the repository url is determined according to the following rules:
# 1. If DEBRICKED_REPOSITORY_URL is set, always use it as the repo url.
# 2. If DEBRICKED_GIT_URL starts with "http(s)://" and ends with ".git", use capture group to set REPOSITORY_URL.
# 3. If DEBRICKED_GIT_URL is of the form "git@github.com:organisation/reponame.git",
#    rewrite and use "https://github.com/organisation/reponame" as REPOSITORY_URL.
# 4. Otherwise, show warning and set repository url to ""
if [ -n "$DEBRICKED_REPOSITORY_URL" ]; then
    REPOSITORY_URL="$DEBRICKED_REPOSITORY_URL"
else
    http_url_regex="^(https?:\/\/.+)\.git$"
    ssh_url_regex="git@(.+):[0-9]*\/?(.+)\.git$"
    if [[ $DEBRICKED_GIT_URL =~ $http_url_regex ]]; then
        REPOSITORY_URL="${BASH_REMATCH[1]}"
    elif [[ $DEBRICKED_GIT_URL =~ $ssh_url_regex ]]; then
        domain="${BASH_REMATCH[1]}"
        uri="${BASH_REMATCH[2]}"
        REPOSITORY_URL="https://${domain}/${uri}"
    else
        echo "INFO: Your repository URL could not be found. Set it manually with DEBRICKED_REPOSITORY_URL"
        REPOSITORY_URL=""
    fi
fi

source "$(dirname "$0")/common.sh"
