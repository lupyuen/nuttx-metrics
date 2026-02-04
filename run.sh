#!/usr/bin/env bash
## See the updated Linux version: run2.sh
## Based on https://imagemagick.org/script/magick-vector-graphics.php

## Don't allow running on macOS
if [ "`uname`" == "Darwin" ]; then
  echo "Quitting on macOS. Should run only on nuttx-dashboard-vm (Ubuntu)"
  exit
fi

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
  local total_job_hours=$(
    grep "^total_job_hours=" $log_file \
    | grep --only-matching -E '[.0-9]+' )
  local total_runner_hours=$(
    grep "^total_runner_hours=" $log_file \
    | grep --only-matching -E '[.0-9]+' )
  local fulltime_runners=$(
    grep "^fulltime_runners=" $log_file \
    | grep --only-matching -E '[.0-9]+' )
  echo time=$time
  echo date=$date
  echo hours=$hours
  echo total_job_hours=$total_job_hours
  echo total_runner_hours=$total_runner_hours
  echo fulltime_runners=$fulltime_runners

  ## Render the Full-Time Runners as Color Gradient (Purple to Orange)
  local percent=$(bc -e "100 * $fulltime_runners / 25")
  local color=483D8B  ## Purple
  if   [[ $percent -gt 95 ]]; then
    color=8B5A00  ## Orange
  elif [[ $percent -gt 90 ]]; then
    color=84570D
  elif [[ $percent -gt 85 ]]; then
    color=7D541B
  elif [[ $percent -gt 80 ]]; then
    color=765129
  elif [[ $percent -gt 75 ]]; then
    color=704E37
  elif [[ $percent -gt 70 ]]; then
    color=694B45
  elif [[ $percent -gt 65 ]]; then
    color=624853
  elif [[ $percent -gt 60 ]]; then
    color=5C4561
  elif [[ $percent -gt 50 ]]; then
    color=55426F
  fi

  ## Populate the ImageMagick Template
  local tmp_file=/tmp/github-fulltime-runners.mvg
  cat github-fulltime-runners.mvg \
    | sed "s/%%color%%/$color/g" \
    | sed "s/%%time%%/$time/g" \
    | sed "s/%%date%%/$date/g" \
    | sed "s/%%hours%%/$hours/g" \
    | sed "s/%%total_job_hours%%/$total_job_hours/g" \
    | sed "s/%%total_runner_hours%%/$total_runner_hours/g" \
    | sed "s/%%fulltime_runners%%/$fulltime_runners/g" \
    >$tmp_file

  ## Render the PNG
  git pull
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
  date
  sleep 900
done
