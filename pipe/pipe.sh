#!/usr/bin/env bash
#
# Pipe for integrating Bitbucket with Debricked. Automatically analyse your latest commits and pull requests for known vulnerabilities.
#

source "$(dirname "$0")/common.sh"

info "Executing the pipe..."

# Required parameters
USERNAME=${USERNAME:?'USERNAME variable missing.'}
PASSWORD=${PASSWORD:?'PASSWORD variable missing.'}
PRODUCT="${BITBUCKET_REPO_OWNER}/${BITBUCKET_REPO_SLUG}"
RELEASE=${BITBUCKET_COMMIT}

# Default parameters
BASE_DIRECTORY=${BASE_DIRECTORY:=""}
RECURSIVE_FILE_SEARCH=${RECURSIVE_FILE_SEARCH:="true"}
DEBUG=${DEBUG:="false"}

SCAN_PARAMETERS="${USERNAME} ${PASSWORD} ${PRODUCT} ${RELEASE} ${BASE_DIRECTORY} --recursive-file-search=${RECURSIVE_FILE_SEARCH}"

if [ ${EXCLUDED_DIRECTORIES+x} ]; then
    SCAN_PARAMETERS="${SCAN_PARAMETERS} --excluded-directories=${EXCLUDED_DIRECTORIES}"
fi

run ~/.composer/vendor/debricked/cli/bin/console debricked:scan ${SCAN_PARAMETERS} -v

if [[ "${output}" =~ "[WARNING] Scan completed" && "${status}" == "0" ]]; then
  fail "Vulnerabilities detected"
elif [[  "${status}" == "0" ]]; then
  success "Success! No vulnerabilities found at time time."
else
  fail "Unknown error, please view pipe output for more details."
fi
