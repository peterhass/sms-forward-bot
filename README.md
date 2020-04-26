# sms-forward-bot
Forwards all SMS received on Netgear LB1110 to a telegram group. 

Practical uses:
- "Redirect" two factor authentication messages to telegram

**Important notes**: 
- Due to limitations in LB1110's software, every forwarded SMS gets deleted on the modem.
- Modem password and sms are transmitted over http (not encrypted)

## Install

- Install HTTPie
- Install jq
- Telegram: Create bot in bot father
- Add bot to your telegram group (or create a new one)
- Gather chat id: `TOKEN="place token here" curl https://api.telegram.org/bot${TOKEN}/getUpdates`
- Clone repo
- Set variables in `script.sh`: TELEGRAM_TOKEN, TELEGRAM_CHAT_ID, MODEM_ADDR, MODEM_PASSWORD
- `crontab -e`

Following crontab will poll sms' every 15 seconds.
```
* * * * * cd /home/you/sms-forward-bot && ./script.sh 2>&1
* * * * * sleep 45; cd /home/you/sms-forward-bot && ./script.sh 2>&1
* * * * * sleep 30; cd /home/you/sms-forward-bot && ./script.sh 2>&1
* * * * * sleep 15; cd /home/you/sms-forward-bot && ./script.sh 2>&1
```
