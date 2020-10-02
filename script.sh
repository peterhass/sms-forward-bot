#!/usr/bin/env bash

source .env.local
TELEGRAM_BOT_BASE="https://api.telegram.org/bot$TELEGRAM_TOKEN"

REDIS="redis-cli"
REDIS_LIST="sms-forward-bot"

$REDIS info clients &> /dev/null
if [ $? -ne 0 ]; then
  echo "Need running redis"
  exit 1
fi

pop_queue() {
  $REDIS --raw BLPOP $REDIS_LIST 10 | tail -n1
}

rpush_queue() {
  $REDIS RPUSH $REDIS_LIST "$1" &> /dev/null
}

lpush_queue() {
  $REDIS LPUSH $REDIS_LIST "$1" &> /dev/null
}

send_telegram() {
  ID="$1"
  RX_TIME="$2"
  TEXT="$3"
  SENDER="$4"
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
}

cleanup() {
  echo "!! CLEANUP !!"

  kill $(jobs -p)
  kill 0
}

mailer() {
  while true; do
    pop_queue | while read line; do
      ! [[ -z "$line" ]] && mailer_process "$line"
    done

    sleep 2
  done
}


mailer_process() {
  ID=`echo $1 | jq -r .id`
  RX_TIME=`echo $1 | jq -r .rxTime`
  TEXT=`echo $1 | jq -r .text`
  SENDER=`echo $1 | jq -r .sender`

  send_telegram "$ID" "$RX_TIME" "$TEXT" "$SENDER" || lpush_queue "$1"
}

collector() {
  while true; do
    found=$(collector_find)

    if ! [[ -z "$found" ]]; then
      echo "$found" | while read message; do
        rpush_queue "$message"
      done
    fi

    sleep 15
  done
}

collector_find() {
  HTTP_SESSION=`mktemp`
  rm "$HTTP_SESSION"

  # create session
  http \
    --headers \
    --ignore-stdin \
    GET http://$MODEM_ADDR/index.html --session="$HTTP_SESSION"  &> /dev/null

  SESSION_ID=`jq -r .cookies.sessionId.value $HTTP_SESSION`
  TOKEN=`echo $SESSION_ID | cut -d'-' -f2`

  http \
    --ignore-stdin \
    --headers \
    --form \
    --session="$HTTP_SESSION" \
    POST http://$MODEM_ADDR/Forms/config \
    token="$TOKEN" \
    "session.password"="$MODEM_PASSWORD" \
    ok_redirect="/index.html" \
    err_redirect="/index.html" &> /dev/null

  data=$(http \
    --ignore-stdin \
    --session="$HTTP_SESSION" \
    GET http://$MODEM_ADDR/api/model.json \
    | jq .sms.msgs)

  echo $data \
    | jq -r 'to_entries | .[] | select(.value.id != null) | .key' \
    | while read smsindex; do
    sms_data=$(echo $data | jq -c -r ".[$smsindex]")
    echo "$sms_data"

    sms_id=`echo $sms_data | jq -r .id`

    http \
      --ignore-stdin \
      --headers \
      --form \
      --session="$HTTP_SESSION" \
      POST http://$MODEM_ADDR/Forms/config \
      token="$TOKEN" \
      ok_redirect="/index.html" \
      err_redirect="/index.html"  \
      "sms.deleteId"="$sms_id" &> /dev/null
  done
}

echo "Starting collector"
collector & 

echo "Starting mailer"
mailer &

trap cleanup EXIT
wait

