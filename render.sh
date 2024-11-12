#!/usr/bin/env bash
## Render the GitHub Metrics periodically

set -x  ## Echo commands

for (( ; ; )); do
  clear
  ./imgcat.sh --width 800px --url https://lupyuen.github.io/nuttx-metrics/github-fulltime-runners.png
  sleep $(( 5 * 60 ))
done
