#!/usr/bin/env bash
## Dump the GitHub Runner History as CSV

set -e  ## Exit when any command fails

## Get the Script Directory
script_path="${BASH_SOURCE}"
script_dir="$(cd -P "$(dirname -- "${script_path}")" >/dev/null 2>&1 && pwd)"

## Run in /tmp because this script will disappear during Git Rewind
if [ "$script_dir" != "/tmp" ] && [ "$script_dir" != "/private/tmp" ]; then
  cp $script_path /tmp/
  /tmp/$script_path
  exit
fi

## Print each CSV Row
## compute-github-runners.log contains:
##   ...
##   date=2026-02-04
##   hours=9
##   total_job_hours=1.8
##   total_runner_hours=14
##   fulltime_runners=1
## We convert to CSV:
##   2026-02-04,9,1.8,14,1
function print_row {
  cat compute-github-runners.log \
    | grep "=" \
    | sed "s/.*=//g" \
    | tr '\n' ','
  echo
}

## Print the CSV Header
echo date,hours,total_job_hours,total_runner_hours,fulltime_runners

## Run forever
for (( ; ; )); do

  ## Print each CSV Row
  print_row

  ## Rewind One Git Commit
  git reset --hard HEAD~1 \
    >/dev/null
done
