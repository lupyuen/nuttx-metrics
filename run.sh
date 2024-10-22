#!/usr/bin/env bash
## Based on https://imagemagick.org/script/magick-vector-graphics.php

## Render the GitHub Metrics
function update_metrics {
  ## For Testing
  # time="Tue Oct 22 02:01:51 UTC 2024"
  # date=2024-10-22
  # hours=3
  # total_runner_hours=3
  # fulltime_runners=1

  ## Compute the Full-Time GitHub Runners
  local log_file=compute-github-runners.log
  $HOME/nuttx-release/compute-github-runners.sh >$log_file

  ## Parse the output
  local time=$(date -u)
  local date=$(
    grep "^date=" $log_file \
    | grep --only-matching -E '[-0-9]+' )
  local hours=$(
    grep "^hours=" $log_file \
    | grep --only-matching -E '[0-9]+' )
  local total_runner_hours=$(
    grep "^total_runner_hours=" $log_file \
    | grep --only-matching -E '[0-9]+' )
  local fulltime_runners=$(
    grep "^fulltime_runners=" $log_file \
    | grep --only-matching -E '[0-9]+' )
  echo time=$time
  echo date=$date
  echo hours=$hours
  echo total_runner_hours=$total_runner_hours
  echo fulltime_runners=$fulltime_runners

  ## Populate the ImageMagick Template
  local tmp_file=/tmp/github-fulltime-runners.mvg
  cat github-fulltime-runners.mvg \
    | sed "s/%%time%%/$time/g" \
    | sed "s/%%date%%/$date/g" \
    | sed "s/%%hours%%/$hours/g" \
    | sed "s/%%total_runner_hours%%/$total_runner_hours/g" \
    | sed "s/%%fulltime_runners%%/$fulltime_runners/g" \
    >$tmp_file

  ## Render the PNG
  magick \
    mvg:$tmp_file \
    github-fulltime-runners.png

  ## Commit the modified files
  git pull
  git status
  git add .
  git commit --all --message="Updated by run.sh"
  git push
}

## Run forever
for (( ; ; )); do
  update_metrics
  sleep 300
done
