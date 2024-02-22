#!/usr/bin/env bash

# If BASE_DIRECTORY is not set, fallback to current directory
if [ -z "$BASE_DIRECTORY" ]
then
  BASE_DIRECTORY=.
else
  BASE_DIRECTORY="${PWD}${BASE_DIRECTORY}"
fi

if command -v git &> /dev/null
then
  git config --global --add safe.directory "$(pwd)"
  AUTHOR=$(git log -1 --pretty=%ae)
fi

debricked scan ${BASE_DIRECTORY} --author=${AUTHOR} --branch=${BITBUCKET_BRANCH} --commit=${BITBUCKET_COMMIT} \
  --integration="bitbucket" --repository="${BITBUCKET_REPO_OWNER}/${BITBUCKET_REPO_SLUG}" \
  --repository-url=${BITBUCKET_GIT_HTTP_ORIGIN}
