#!/usr/bin/env python3
import argparse
import json
from telnetlib import Telnet

from receive_sms.parse import parse_modem_messages, merge_partial_messages

PORT = 5510


def disable_echo(tn):
    tn.write(b"ATE0\r")
    tn.read_until(b"OK\r\n")


def format_message_for_output(message):
    return {
        'text': message["content"],
        'sender': message["sender"],
        'rxTime': message["date"].strftime("%d.%m.%Y %H:%M:%S")
    }


def run_cli():
    parser = argparse.ArgumentParser(description="Receive SMS from modem")
    parser.add_argument('host')
    parser.add_argument('-f', '--flush', action="store_true")
    args = parser.parse_args()

    with Telnet(args.host, PORT) as tn:
        disable_echo(tn)
        tn.write(b"AT+CMGL=4\r")
        response = tn.read_until(b"OK\r\n")
        raw_messages_by_index = parse_modem_messages(response)
        messages = merge_partial_messages(raw_messages_by_index)

        print(json.dumps(list(map(format_message_for_output, messages))))

        if args.flush:
            indicies = [*raw_messages_by_index]
            for index in indicies:
                tn.write((f"AT+CMGD={index}\r").encode())
                tn.read_until(b"OK\r\n")
