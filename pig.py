import os, requests, json, pigpio, time, fcntl, struct, socket, sys, datetime
sys.path.insert(0, '/home/pi/apps/PIGPIO/')
pi = pigpio.pi()
import DHT22

dow = datetime.datetime.today().weekday()

def get_ip_address(ifname):
    so= socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return socket.inet_ntoa(fcntl.ioctl(
        so.fileno(),
        0x8915,  # SIOCGIFADDR
        struct.pack('256s', ifname[:15])
    )[20:24])

s = DHT22.sensor(pi, 18)
s.trigger()
time.sleep(0.2)

#humid = '{:3.2f}'.format(s.humidity() / 1.)
#temp = '{:3.2f}'.format(s.temperature() / 1.)
#url = get_ip_address('eth0')
url = get_ip_address('wlan0')
my_url = "http://%(url)s:4567/record" % locals()
#data = json.dumps({"content": "json from pi", "temperature": "\n#{temp}", "humidity": "\n{humid}"})

data = json.dumps({"content": "%(dow)s | json from pi", "temperature": "%(temp)s", "humidity": "%(humid)s"}) % {"dow" : dow, "humid" : '{:3.2f}'.format(s.humidity() / 1.), "temp" : '{:3.2f}'.format(s.temperature() / 1.)}
req = requests.post(my_url, data)
print req.json
#print('{:3.2f}'.format(s.humidity() / 1.))
#time.sleep(0.2)
#print('{:3.2f}'.format(s.temperature() / 1.))
s.cancel()
#pi.stop()
