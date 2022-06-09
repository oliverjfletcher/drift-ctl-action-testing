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

scan_output() {
  # Store scan output in variable 
  scan_output="$(driftctl scan $qflag $INPUT_ARGS)"
  echo $scan_ouput
  ret_code=$?
  return $ret_code
}

#Run scan_ouput function and store in var
scan_output=$(scan_output)

echo $scan_output

# Set output to be used for other Github Actions jobs
echo "::set-output name=driftctl::$scan_output"