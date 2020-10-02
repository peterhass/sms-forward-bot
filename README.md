# sms-forward-bot
Forwards all SMS received on Netgear LB1110 to a telegram group. 

Practical uses:
- "Redirect" two factor authentication messages to telegram

**Important notes**: 
- Due to limitations in LB1110's software, every forwarded SMS gets deleted on the modem.
- Modem password and sms are transmitted over http (not encrypted)

## Install

- Install redis (TODO document setup)
- Install HTTPie
- Install jq
- Telegram: Create bot in bot father
- Add bot to your telegram group (or create a new one)
- Gather chat id: `TOKEN="place token here" curl https://api.telegram.org/bot${TOKEN}/getUpdates`
- Clone repo
- `cp .env.example .env.local`
- Update all needed variables in `.env.local`
- Install as service (TODO documention needed)

## TODO

- Setup as a service
- Automatic modem restart to prevent it from freezing up
- Refactoring
