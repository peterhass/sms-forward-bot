#!/bin/bash 
ACTIVE_PID=`cat active.pid 2>/dev/null`
if kill -s 0 $ACTIVE_PID 2>/dev/null; then
  echo "Other instance active. Check active.pid"
  exit
fi
echo $$ > active.pid

export TELEGRAM_TOKEN="FILL IN"
export TELEGRAM_CHAT_ID="FILL IN"
export MODEM_ADDR="FILL IN"
export TELEGRAM_BOT_BASE="https://api.telegram.org/bot$TELEGRAM_TOKEN"
export HTTP_SESSION=`mktemp`
export LAST_NOTIFIED_FILE="./last_notified"
export MODEM_PASSWORD="password"

rm "$HTTP_SESSION"

# create session
http \
  --headers \
  --ignore-stdin \
  GET http://$MODEM_ADDR/index.html --session="$HTTP_SESSION" \

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
  err_redirect="/index.html" 


http \
  --ignore-stdin \
  --session="$HTTP_SESSION" \
  GET http://$MODEM_ADDR/api/model.json \
  | \
  jq .sms.msgs > all_sms.json

LAST_ID=`jq -r '.[].id' all_sms.json | sort -n | tail -n1`

if [ "$LAST_ID" == "null" ]; then
  echo "No new messages available"
  
  exit
fi

LAST_NOTIFIED_ID=`cat $LAST_NOTIFIED_FILE 2>/dev/null`
[ -z $LAST_NOTIFIED_ID ] && LAST_NOTIFIED_ID=0

jq -r 'to_entries | .[] | select(.value.id != null and (.value.id|tonumber)>'$LAST_NOTIFIED_ID') | .key' ./all_sms.json \
  | while read smsindex; do
  
  ID=`jq -r ".[$smsindex].id" ./all_sms.json`
  RX_TIME=`jq -r ".[$smsindex].rxTime" ./all_sms.json`
  TEXT=`jq -r ".[$smsindex].text" ./all_sms.json`
  SENDER=`jq -r ".[$smsindex].sender" ./all_sms.json`
  EMOJI=`echo -e '\xF0\x9F\x93\xAC'`

  MESSAGE=`printf '*%s NEUE SMS! %s NEUE SMS! %s* \n\n*%s*\n*%s*\n\n%b' "$EMOJI" "$EMOJI" "$EMOJI" "$SENDER" "$RX_TIME" "$TEXT"`

  http \
	--ignore-stdin \
	--headers \
	POST "$TELEGRAM_BOT_BASE/sendMessage" \
	chat_id="$TELEGRAM_CHAT_ID" \
	parse_mode=markdown \
	text="$MESSAGE" 

  http \
    --ignore-stdin \
    --headers \
    --form \
    --session="$HTTP_SESSION" \
    POST http://$MODEM_ADDR/Forms/config \
    token="$TOKEN" \
    ok_redirect="/index.html" \
    err_redirect="/index.html"  \
    "sms.deleteId"="$ID"
done

echo $LAST_ID > $LAST_NOTIFIED_FILE
rm "$HTTP_SESSION"

