#!/usr/bin/env bash
#
# Step for integrating Azure DevOps with Debricked. Automatically analyse your latest commits and pull requests for known vulnerabilities.
#

REPOSITORY="${SYSTEM_TEAMPROJECT}/${BUILD_REPOSITORY_NAME}"
COMMIT=${BUILD_SOURCEVERSION}
BRANCH=${BUILD_SOURCEBRANCHNAME}
BASE_DIRECTORY=${BUILD_SOURCESDIRECTORY}

source "$(dirname "$0")/common.sh"
