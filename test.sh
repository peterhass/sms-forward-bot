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

  echo $1 | jq ".[]"
  # $1 will be json, so we can use jq to split it up
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
  # load sms into $data
  data=$(cat ./beispiel.json)

  echo $data \
    | jq -r 'to_entries | .[] | .key' \
    | while read smsindex; do
    echo $(echo $data | jq -c -r ".[$smsindex]")

    # modem: delete sms after output
  done
}

echo "Starting collector"
collector & 

echo "Starting mailer"
mailer &

trap cleanup EXIT
wait

