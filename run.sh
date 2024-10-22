#!/usr/bin/env bash
## Based on https://imagemagick.org/script/magick-vector-graphics.php

# time="Tue Oct 22 02:01:51 UTC 2024"
# date=2024-10-22
# hours=3
# total_runner_hours=3
# fulltime_runners=1

log_file=/tmp/compute-github-runners.log
$HOME/nuttx-release/compute-github-runners.sh >$log_file

time=$(date -u)
date=$(
  grep "^date=" $log_file \
  | grep --only-matching -E '[-0-9]+' )
hours=$(
  grep "^hours=" $log_file \
  | grep --only-matching -E '[0-9]+' )
total_runner_hours=$(
  grep "^total_runner_hours=" $log_file \
  | grep --only-matching -E '[0-9]+' )
fulltime_runners=$(
  grep "^fulltime_runners=" $log_file \
  | grep --only-matching -E '[0-9]+' )
echo time=$time
echo date=$date
echo hours=$hours
echo total_runner_hours=$total_runner_hours
echo fulltime_runners=$fulltime_runners

tmp_file=/tmp/github-fulltime-runners.mvg
cat github-fulltime-runners.mvg \
  | sed "s/%%time%%/$time/g" \
  | sed "s/%%date%%/$date/g" \
  | sed "s/%%hours%%/$hours/g" \
  | sed "s/%%total_runner_hours%%/$total_runner_hours/g" \
  | sed "s/%%fulltime_runners%%/$fulltime_runners/g" \
  >$tmp_file

magick \
  mvg:$tmp_file \
  github-fulltime-runners.png
