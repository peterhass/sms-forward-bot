#!/usr/bin/env bash

source .env.local
TELEGRAM_BOT_BASE="https://api.telegram.org/bot$TELEGRAM_TOKEN"

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

push_queue() {
  echo "Pushing to queue"

  # TODO: handle lock because multiple 
  # TODO:  processes may call this fn
  echo $1 > $PIPE
}

mailer_process() {
  ID=`echo $1 | jq -r ".[$smsindex].id"`
  RX_TIME=`echo $1 | jq -r ".[$smsindex].rxTime"`
  TEXT=`echo $1 | jq -r ".[$smsindex].text"`
  SENDER=`echo $1 | jq -r ".[$smsindex].sender"`
  EMOJI=`echo -e '\xF0\x9F\x93\xAC'`

  MESSAGE=`printf '*%s NEUE SMS! %s NEUE SMS! %s* \n\n*%s*\n*%s*\n\n%b' "$EMOJI" "$EMOJI" "$EMOJI" "$SENDER" "$RX_TIME" "$TEXT"`

  http \
        --check-status \
	--ignore-stdin \
	--headers \
	POST "$TELEGRAM_BOT_BASE/sendMessage" \
	chat_id="$TELEGRAM_CHAT_ID" \
	parse_mode=markdown \
	text="$MESSAGE" 

  # re-add to queue
  if [ $? -neq 0 ]; then
    push_queue "$1"
  fi
}

# collects sms and adds them to the queue
collector() {
  while true; do
    found=$(collector_find)

    if ! [[ -z "$found" ]]; then
      push_queue "$found"
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

