import sys
import subprocess
from mpd import MPDClient


def start_mpd():
    sprocess = subprocess.run(
        ['systemctl', '--user', 'is-active', 'mpd.service']
    )
    if sprocess.returncode != 0:
        subprocess.run(['systemctl', '--user', 'start', 'mpd.service'])

    sprocess = subprocess.run(['pgrep', 'mpdscribble'])
    if sprocess.returncode != 0:
        subprocess.run(['mpdscribble'])


def random_toggle(mpd_client):
    if mpd_client.status()['random'] == '0':
        mpd_client.random(1)
        subprocess.run(['notify-send', 'Random mode turned on.'])
    elif mpd_client.status()['random'] == '1':
        mpd_client.random(0)
        subprocess.run(['notify-send', 'Random mode turned off.'])


# initialize mpd connection
mpd_client = MPDClient()
try:
    mpd_client.connect('localhost', 6600)
except ConnectionRefusedError:
    start_mpd()

# parse start-up parameter
try:
    command = sys.argv[1]
except IndexError:
    sys.exit(1)

if command == 'playpause':
    mpd_client.pause()
elif command == 'next':
    mpd_client.next()
elif command == 'previous':
    mpd_client.previous()
elif command == 'random_toggle':
    random_toggle(mpd_client)
