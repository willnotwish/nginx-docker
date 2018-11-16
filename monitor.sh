#!/usr/bin/env bash

# nginx commands
RELOAD_CMD="nginx -s reload"
CHECK_CMD="nginx -t"

# Default timeout is 24 hours
RELOAD_TIMEOUT=${RELOAD_TIMEOUT:-"86400"}

# This is the time we wait for after detecting a command: just in case there are several of them at once
DEBOUNCE_PERIOD=10

echo "monitor.sh: About to start. Reload command: $RELOAD_CMD"

while true; do
  echo "monitor.sh: In loop. About to wait on /monitor/reload.txt with timeout of $RELOAD_TIMEOUT seconds"
  inotifywait --timeout $RELOAD_TIMEOUT /monitor/

  echo "monitor.sh. Debounce period. Sleeping for a further 10 seconds"
  sleep $DEBOUNCE_PERIOD

  echo "monitor.sh. About to check and reload nginx with: $CHECK_CMD and $RELOAD_CMD"
  $CHECK_CMD && $RELOAD_CMD
done

