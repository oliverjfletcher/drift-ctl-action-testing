#!/bin/sh

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

# Get exit code for scan, format output and set ouput
scan_output(){
  scan_output="$(driftctl scan $qflag $INPUT_ARGS)"
  exit_code=$?
  if [[ $exit_code -eq 0 || $exit_code -eq 1 ]]; then
    scan_output="${scan_output//$'\n'/'%0A'}"
    echo "$scan_output"
    exit 1
  else
    scan_output="${scan_output//$'\n'/'%0A'}"
    echo "$scan_output"
    exit 1
  fi
}
# Run scan function and store in variable
scan_output=$(echo -e "$(scan_output)")

#Echo scan function output
echo -e "$scan_output"

# Set output to be used for other Github Actions jobs
echo "::set-output name=driftctl::$scan_output"


