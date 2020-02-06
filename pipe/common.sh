#!/bin/bash

# Common script helper code for writing bash based pipes
# This file needs to be 'source'd from your bach script, i.e. `source common.sh`
# This supplies the `info()`, `error()`, `debug()`, `success()` and `fail()` command that will
# color the output consistently with other Pipes.
#
# We also recommend that your Pipe contain a `DEBUG` variable, which when set to `true`
# enables extra debug output - this can be achieved simply by calling the `enable_debug()`
# function from within your Pipe script and using the `debug()` function which will conditionally emit
# debugging information.

set -e
set -o pipefail

gray="\\e[37m"
blue="\\e[36m"
red="\\e[31m"
green="\\e[32m"
reset="\\e[0m"

# Output information to the Pipelines log for the user
info() { echo -e "${blue}INFO: $*${reset}"; }
# Output high-visibility error information
error() { echo -e "${red}ERROR: $*${reset}"; }
# Conditionally output debug information (if DEBUG==true)
debug() {
    if [[ "${DEBUG}" == "true" ]]; then
        echo -e "${gray}DEBUG: $*${reset}";
    fi
}

# Output log information indicating success
success() { echo -e "${green}✔ $*${reset}"; }
# Output log information indicating failure and exit the Pipe script
fail() { echo -e "${red}✖ $*${reset}"; exit 1; }

# Enable debug mode.
enable_debug() {
  if [[ "${DEBUG}" == "true" ]]; then
    info "Enabling debug mode."
    set -x
  fi
}

# Execute a command, saving its output and exit status code, and echoing its output upon completion.
# Globals set:
#   status: Exit status of the command that was executed.
#   output: Output generated from the command.
#
run() {
  echo "$@"
  set +e
  output=$("$@" 2>&1)
  status=$?
  set -e
  echo "${output}"
}

info "Executing the pipe..."

# Required parameters
USERNAME=${USERNAME:?'USERNAME variable missing.'}
PASSWORD=${PASSWORD:?'PASSWORD variable missing.'}

# Default parameters
BASE_DIRECTORY=${BASE_DIRECTORY:=""}
RECURSIVE_FILE_SEARCH=${RECURSIVE_FILE_SEARCH:="true"}
DEBUG=${DEBUG:="false"}
REPOSITORY_URL=${REPOSITORY_URL:=""}
UPLOAD_ALL_FILES=${UPLOAD_ALL_FILES:="false"}
SKIP_SCAN=${SKIP_SCAN:="false"}
SCAN_PARAMETERS="${USERNAME} ${PASSWORD} ${REPOSITORY} ${COMMIT}  ${REPOSITORY_URL} ${INTEGRATION_NAME} ${BASE_DIRECTORY} --recursive-file-search=${RECURSIVE_FILE_SEARCH}"

if [ ! -z "$BRANCH" ]; then
    SCAN_PARAMETERS="${SCAN_PARAMETERS} --branch-name=${BRANCH}"
fi

if [ ${EXCLUDED_DIRECTORIES+x} ]; then
    SCAN_PARAMETERS="${SCAN_PARAMETERS} --excluded-directories=${EXCLUDED_DIRECTORIES}"
fi

if [[ "${UPLOAD_ALL_FILES}" == "true" ]]; then
    SCAN_PARAMETERS="${SCAN_PARAMETERS} --upload-all-files=${UPLOAD_ALL_FILES}"
fi

if [[ "${SKIP_SCAN}" == "true" ]]; then
  run ~/.composer/vendor/debricked/cli/bin/console debricked:find-and-upload-files ${SCAN_PARAMETERS} -v
else
  run ~/.composer/vendor/debricked/cli/bin/console debricked:scan ${SCAN_PARAMETERS} -v
fi

vulnerabilitiesOutputRegex='\[ERROR\]\s+Scan completed'
if [[ "${SKIP_SCAN}" == "true" && "${status}" == "0" ]]; then
  success "Files were successfully uploaded, scan result will be available at https://app.debricked.com in a short while."
elif [[ "${output}" =~ $vulnerabilitiesOutputRegex && "${status}" == "0" ]]; then
  fail "Vulnerabilities detected"
elif [[  "${status}" == "0" ]]; then
  success "Success! No vulnerabilities found at this time."
else
  fail "Unknown error, please view pipe output for more details."
fi
