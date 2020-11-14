# sms-forward-bot
Forwards all SMS received on Netgear LB1110 to a telegram group. 

Practical uses:
- "Redirect" two factor authentication messages to telegram

**Important notes**: 
- Due to limitations in LB1110's software, every forwarded SMS gets deleted on the modem.
- Modem password and sms are transmitted over http (not encrypted)

## Install

- Install redis
- Install HTTPie
- Install jq
- Telegram: Create bot in bot father
- Add bot to your telegram group (or create a new one)
- Gather chat id: `TOKEN="place token here" curl https://api.telegram.org/bot${TOKEN}/getUpdates`
- `git clone https://github.com/peterhass/sms-forward-bot.git`
- `cp .env.example .env.local`
- Update all needed variables in `.env.local`
- Try out if your config works: `source .env.local && ./script.sh`
- Add `sms-forward-bot` user and group
- `make install`
- `systemctl daemon-reload && systemctl start sms-forward-bot.service`
- Start on reboot: `systemctl enable sms-forward-bot.service && systemctl enable --now sms-modem-restart.timer`
