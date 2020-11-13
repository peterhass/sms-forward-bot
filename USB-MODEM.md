huawei e3531

- braucht modeset
- chmod 666 /dev/ttyUSB0 && cu -l /dev/ttyUSB0
- ATE1 enable echo
- check sim AT+CPIN?
ATE1
AT+CMGF=1
AT+CMGL="ALL"

https://www.developershome.com/sms/howToReceiveSMSUsingPC.asp
https://www.developershome.com/sms/cmgrCommand.asp
https://www.hologram.io/blog/using-at-commands-with-the-huawei-e303

Ich glaube es wird am einfachsten einfach direkt über das serielle Interface
mit dem Modem zu kommunizieren

Müssen SMS gelöscht werden nachdem man sie abgeholt hat?
Wie ist das Encoding?

um eine nachricht zu versenden

AT+CMGF=0
AT+CMGW="+436641177508"
AT+CMSS=? (nummer von vorher)
// nachricht tippen
strg z



https://github.com/babca/python-gsmmodem/blob/master/gsmmodem/modem.py
