#!/bin/bash

log_error() {
  echo $1
  exit 1
}

install_driftctl() {
  echo "Installing dctlenv"
  git clone --depth 1 --branch v0.1.8 https://github.com/wbeuil/dctlenv ~/.dctlenv
  export PATH="$HOME/.dctlenv/bin:$PATH"

  gpg --keyserver hkps://keys.openpgp.org --recv-keys 0xACC776A79C824EBD

  echo "Downloading driftctl:$version"
  DCTLENV_CURL=1 dctlenv use $version
}

parse_inputs() {
  # Required inputs
  if [ "$INPUT_VERSION" != "" ]; then
    version=$INPUT_VERSION
  else
    log_error "Input version cannot be empty"
  fi
}

quiet_flag() {
  if version_le "${version/v/}" "0.6.0"; then
    return
  fi
  qflag="--quiet"
}

version_le() {
  [ "$1" = "`echo -e "$1\n$2" | sort -V | head -n 1`" ]
}

# First we need to parse inputs
parse_inputs

# Then we install the requested driftctl binary
install_driftctl || log_error "Fail to install driftctl"

# We check if the version of driftctl needs the quiet flag
qflag=""
quiet_flag

# Get exit code for scan, format output and return exit code from scan
scan_output(){
    scan_output="$(driftctl scan $qflag $INPUT_ARGS;return)" 
    exit_code=$?
    echo -e $scan_output
    return $exit_code
}
# Run scan function and pass in argument
scan_output=$(scan_output)

# Format output to be consumed by Github Actions runner console
scan_output="${scan_output//'%'/'%25'}"

# Echo scan output to be consumed through Github Actions runner console
echo -e "$scan_output"

# Format output again to be added to GitHub comment
scan_output="${scan_output//$'\n'/'%0A'}"

# Set output to be used for other Github Actions jobs
echo "::set-output name=driftctl::$scan_output"


