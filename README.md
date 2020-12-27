# sms-forward-bot
Forwards all SMS received on Netgear LB1110 to a telegram group. 

Practical uses:
- "Redirect" two factor authentication messages to telegram

**Important notes**: 
- Due to limitations in LB1110's software, every forwarded SMS gets deleted on the modem.
- Due to limitations in LB1110's software, sms with multiple newlines may appear as multiple messages.
- Modem password and sms are transmitted over http (not encrypted). Don't connect the modem to your network, hook it directly into your machine.

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
- `cp /etc/sms-forward-bot.env_example /etc/sms-forward-bot.env`
- Update all needed variables in `vim /etc/sms-forward-bot.env`
- `systemctl start sms-forward-bot.service`
- Start on reboot: `systemctl enable sms-forward-bot.service && systemctl enable --now sms-modem-restart.timer`

## Update existing installation

Imprtant note: This will overwrite the systemd services and timers

- `cd sms-forward-bot`
- `git pull`
- `make install`
