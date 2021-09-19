
check-deps:
	command -v bash &> /dev/null || { echo >&2 "Requires bash" exit 1; }
	command -v redis-cli &> /dev/null || { echo >&2 "Requires redis-cli" exit 1; }
	command -v http &> /dev/null || { echo >&2 "Requires httpie" exit 1; }
	command -v ruby &> /dev/null || { echo >&2 "Requires ruby" exit 1; }
	command -v python3 &> /dev/null || { echo >&2 "Requires python3" exit 1; }

install: check-deps
	cp ./sms-forward-bot /usr/local/bin/sms-forward-bot
	cp ./sms-forward-bot.env /etc/sms-forward-bot.env_example
	cp ./sms-forward-bot.service /etc/systemd/system/
	cp ./sms-modem-restart.service /etc/systemd/system/
	cp ./sms-modem-restart.timer /etc/systemd/system/
	(cd receive_sms && python3 setup.py install)
	systemctl daemon-reload 

