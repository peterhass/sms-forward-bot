#!/usr/bin/env bash

PIPE="$1"

if ! [[ -p "$PIPE" ]]; then
  echo "Usage: $0 [fifo]"
  echo "Initialize fifo file with mkfifo"
  exit 1
fi


cleanup() {
  echo "!! CLEANUP !!"

  kill $(jobs -p)
  kill 0
}

# reads from the queue and sends out notifications
mailer() {
  while true; do
    cat $PIPE | while read line; do
      mailer_process "$line"
    done
  done
}

mailer_process() {
  echo "mailer_process: $1"
  # send out telegram notification
}

# collects sms and adds them to the queue
collector() {
  while true; do
    found=$(collector_find)

    if ! [[ -z "$found" ]]; then
      echo "Writing to pipe"
      echo "$found" > $PIPE
    fi

    sleep 2 
  done
}

collector_find() {
  # receive sms here
  # return empty str if nothing is there
  date
}

echo "Starting collector"
collector & 

echo "Starting mailer"
mailer &

trap cleanup EXIT
wait

