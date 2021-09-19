import datetime
import unittest

from receive_sms.receive_sms.parse import parse_modem_messages, merge_partial_messages


class TestParse(unittest.TestCase):
    def test_merge_partial_messages(self):
        MESSAGES = {
            0: {
                'sender': '+436641177508',
                'date': datetime.datetime(2021, 9, 19, 11, 22, 15, tzinfo=datetime.timezone.utc),
                'content': 'Start LOL -(:€&3@,!€;&:@(&","?\'dnbsmfncnmskdj1234567009-/:;())€&&@"',
                'partial': {'reference': '8-3', 'parts_count': 3, 'part_number': 1}
            },
            1: {
                'sender': '+436641177508',
                'date': datetime.datetime(
                    2021, 9, 19, 11, 22, 21,
                    tzinfo=datetime.timezone.utc),
                'content': 'Das ist eine kurze SMS!',
                'partial': False
            },
            2: {
                'sender': '+436641177508',
                'date': datetime.datetime(2021, 9, 19, 11, 22, 16, tzinfo=datetime.timezone.utc),
                'content': ".,?!'🥸🥳🤣🇨🇿🏴\U000e0067\U000e0062\U000e0073\U000e0063\U000e0074\U000e007f🇹🇭🏴\U000e0067\U000e0062\U000e0077\U000e006c\U000e0073\U000e007f🇹🇩🇬🇧🎑😃😅🥸🙃🙂",
                'partial': {'reference': '8-3', 'parts_count': 3, 'part_number': 2}
            },
            3: {
                'sender': '+436641177508',
                'date': datetime.datetime(
                    2021, 9, 19, 11, 22, 16,
                    tzinfo=datetime.timezone.utc),
                'content': '🤓🧐🤣🏮📭📭🪅📬📭🪄🎀\nLOL ',
                'partial': {
                    'reference': '8-3',
                    'parts_count': 3,
                    'part_number': 3}
            }
        }

        merged = merge_partial_messages(MESSAGES)
        self.assertEqual(merged, [
            {'sender': '+436641177508',
             'date': datetime.datetime(2021, 9, 19, 11, 22, 15, tzinfo=datetime.timezone.utc),
             'content': 'Start LOL -(:€&3@,!€;&:@(&","?\'dnbsmfncnmskdj1234567009-/:;())€&&@".,?!\'🥸🥳🤣🇨🇿🏴\U000e0067\U000e0062\U000e0073\U000e0063\U000e0074\U000e007f🇹🇭🏴\U000e0067\U000e0062\U000e0077\U000e006c\U000e0073\U000e007f🇹🇩🇬🇧🎑😃😅🥸🙃🙂🤓🧐🤣🏮📭📭🪅📬📭🪄🎀\nLOL ',
             'partial': 'merged'
             },
            {'sender': '+436641177508',
             'date': datetime.datetime(2021, 9, 19, 11, 22, 21, tzinfo=datetime.timezone.utc),
             'content': 'Das ist eine kurze SMS!', 'partial': False
             }
        ])

    def test_parse_modem_messages(self):
        TWO_MESSAGE_RESPONSE_WITH_CONCAT = b'\r\n+CMGL: 0,0,,159\r\n069134660405F1440C913466147157800008129091312251808C050003080301005300740061007200740020004C004F004C0020002D0028003A20AC002600330040002C002120AC003B0026003A0040002800260022002C0022003F00270064006E00620073006D0066006E0063006E006D0073006B0064006A0031003200330034003500360037003000300039002D002F003A003B00280029002920AC0026002600400022\r\n+CMGL: 1,0,,40\r\n069134660405F1040C9134661471578000001290913122128017C4F01C949ED341E5B4BB0C5AD7E5FA3268DA9C8600\r\n+CMGL: 2,0,,159\r\n069134660405F1400C913466147157800008129091312261808C050003080302002E002C003F00210027D83EDD78D83EDD73D83EDD23D83CDDE8D83CDDFFD83CDFF4DB40DC67DB40DC62DB40DC73DB40DC63DB40DC74DB40DC7FD83CDDF9D83CDDEDD83CDFF4DB40DC67DB40DC62DB40DC77DB40DC6CDB40DC73DB40DC7FD83CDDF9D83CDDE9D83CDDECD83CDDE7D83CDF91D83DDE03D83DDE05D83EDD78D83DDE43D83DDE42\r\n+CMGL: 3,0,,79\r\n069134660405F1440C913466147157800008129091312261803C050003080303D83EDD13D83EDDD0D83EDD23D83CDFEED83DDCEDD83DDCEDD83EDE85D83DDCECD83DDCEDD83EDE84D83CDF80000A004C004F004C0020\r\n\r\nOK\r\n'
        messages = parse_modem_messages(TWO_MESSAGE_RESPONSE_WITH_CONCAT)
        self.assertEqual(messages, {
            0: {
                'sender': '+436641177508',
                'date': datetime.datetime(2021, 9, 19, 11, 22, 15, tzinfo=datetime.timezone.utc),
                'content': 'Start LOL -(:€&3@,!€;&:@(&","?\'dnbsmfncnmskdj1234567009-/:;())€&&@"',
                'partial': {'reference': '8-3', 'parts_count': 3, 'part_number': 1}
            },
            1: {
                'sender': '+436641177508',
                'date': datetime.datetime(
                    2021, 9, 19, 11, 22, 21,
                    tzinfo=datetime.timezone.utc),
                'content': 'Das ist eine kurze SMS!',
                'partial': False
            },
            2: {
                'sender': '+436641177508',
                'date': datetime.datetime(2021, 9, 19, 11, 22, 16, tzinfo=datetime.timezone.utc),
                'content': ".,?!'🥸🥳🤣🇨🇿🏴\U000e0067\U000e0062\U000e0073\U000e0063\U000e0074\U000e007f🇹🇭🏴\U000e0067\U000e0062\U000e0077\U000e006c\U000e0073\U000e007f🇹🇩🇬🇧🎑😃😅🥸🙃🙂",
                'partial': {'reference': '8-3', 'parts_count': 3, 'part_number': 2}
            },
            3: {
                'sender': '+436641177508',
                'date': datetime.datetime(
                    2021, 9, 19, 11, 22, 16,
                    tzinfo=datetime.timezone.utc),
                'content': '🤓🧐🤣🏮📭📭🪅📬📭🪄🎀\nLOL ',
                'partial': {
                    'reference': '8-3',
                    'parts_count': 3,
                    'part_number': 3}
            }
        })
