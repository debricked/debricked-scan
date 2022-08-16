#!/usr/bin/env bash

#
# Pipe for integrating Travis-CI with Debricked. Automatically analyse your latest commits and pull requests for known vulnerabilities.
#

USERNAME="${DEBRICKED_USERNAME}"
PASSWORD="${DEBRICKED_PASSWORD}"

if [ -n "$DEBRICKED_REPOSITORY_URL" ]; then
    REPOSITORY_URL="$DEBRICKED_REPOSITORY_URL"
else
    echo "INFO: Your repository URL could not be found. Set it manually with DEBRICKED_REPOSITORY_URL"
    REPOSITORY_URL=""
fi

# The slug (in form: owner_name/repo_name) of the repository currently being built.
REPOSITORY="${TRAVIS_REPO_SLUG}"

# for push builds, or builds not triggered by a pull request, this is the name of the branch.
# for builds triggered by a pull request this is the name of the branch targeted by the pull request.
# for builds triggered by a tag, this is the same as the name of the tag (TRAVIS_TAG)
BRANCH="${TRAVIS_BRANCH}"

# The commit that the current build is testing.
COMMIT="${TRAVIS_COMMIT}"

INTEGRATION_NAME=travis

# The absolute path to the directory where the repository being built has been copied on the worker.
# HOME is set to /home/travis on Linux, /Users/travis on MacOS, and /c/Users/travis on Windows.
BASE_DIRECTORY=${TRAVIS_BUILD_DIR}


# Set to true if the job is running in debug mode
DEBUG=${TRAVIS_DEBUG_MODE:="false"}
RECURSIVE_FILE_SEARCH=${RECURSIVE_FILE_SEARCH:="true"}
UPLOAD_ALL_FILES=${UPLOAD_ALL_FILES:="false"}
SKIP_SCAN=${SKIP_SCAN:="false"}
DISABLE_CONDITIONAL_SKIP_SCAN=${DISABLE_CONDITIONAL_SKIP_SCAN:="false"}

if command -v git &> /dev/null
then
  AUTHOR=$(git log -1 --pretty=%ae)
fi

source "$(dirname "$0")/common.sh"
