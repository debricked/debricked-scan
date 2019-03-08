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

