#!/usr/bin/python
import os
import time

import paho.mqtt.client as mqtt

from picamera import PiCamera

Broker = "localhost"
topic_gps = "sensors/gps"

dir_home = "/home/pi/camera/photos/"  # with trailing slash !

last_gps = {}


#### MQTT flavor

def on_connect(client, userdata, flags, rc):
    print("Connected with result code " + str(rc))
    # client.subscribe(sub_topic)


def on_message(client, userdata, msg):
    global last_gps
    global last_temp
    # print("recieved  " + str(msg))

    topic = msg.topic
    message = str(msg.payload.decode("utf-8", "ignore"))

    if topic == topic_gps:
        # print("updating last_gps [" + str(last_gps) + "} ")
        last_gps = message
        # print("new last_gps [" + str(last_gps) + "} ")


# client = mqtt.Client()
# client.on_connect = on_connect
# client.on_message = on_message
# client.connect(Broker, 1883, 60)
# client.subscribe(topic_gps)
# client.loop_start()


camera = PiCamera()
camera.resolution = (2592, 1944)

current_time = time.localtime(time.time())
dir_name = (str(current_time[0]) + "-" + str(current_time[1]) + "-" + str(current_time[2]) + "_" +
            str(current_time[3]) + "-" + str(current_time[4]))
print("creating sub directory " + str(dir_name))
try:
    os.stat(dir_home + dir_name)
except:
    os.mkdir(dir_home + dir_name)

i = 1
while True:
    time.sleep(2)
    camera.capture(dir_home + dir_name + '/image%s.jpg' % i)
    # exit(0)
    i += 1
