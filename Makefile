
check-deps:
	command -v bash &> /dev/null || { echo >&2 "Requires bash" exit 1; }
	command -v redis-cli &> /dev/null || { echo >&2 "Requires redis-cli" exit 1; }
	command -v http &> /dev/null || { echo >&2 "Requires httpie" exit 1; }

install: check-deps
	cp ./script.sh /usr/local/bin/sms-forward-bot