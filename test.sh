#!/bin/sh
#command="$(driftctl scan --from tfstate+s3://useds3b000/global/s3/terraform.tfstate)"
command="$(aws-vault exec terraform -- driftctl scan --from tfstate+s3://useds3b000/global/s3/terraform.tfstate)"

scan_ouput(){
  scan_output="($command)"
  exit_code=$?
  if [[ "$exit_code" -ne 0 || "$exit_code" -ne 1 ]]; then
    echo "the thing failed"
    return
  else
    echo "$scan_output"
    scan_output="${scan_output//$'\n'/'%0A'}"
    echo "hello from bash"
  fi
}
scan_ouput
scan_output=($scan_output)

echo $scan_output
