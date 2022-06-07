#!/usr/bin/env bash
#
# Step for integrating Azure DevOps with Debricked. Automatically analyse your latest commits and pull requests for known vulnerabilities.
#

HOME=/root
OWNER=$(basename "${SYSTEM_COLLECTIONURI}")
REPOSITORY="${OWNER}/${BUILD_REPOSITORY_NAME}"
COMMIT=${BUILD_SOURCEVERSION}
BRANCH=${BUILD_SOURCEBRANCHNAME}
BASE_DIRECTORY=${BUILD_SOURCESDIRECTORY}
REPOSITORY_URL=${BUILD_REPOSITORY_URI}
INTEGRATION_NAME=azureDevOps
AUTHOR=${BUILD_REQUESTEDFOREMAIL}
source "$(dirname "$0")/common.sh"
