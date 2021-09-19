from setuptools import setup

if __name__ == '__main__':
    setup(
        name='receive_sms',
        version='0.1',
        description='',
        scripts=['bin/receive_sms'],
        packages=['receive_sms'],
        install_requires=['smspdudecoder']
    )