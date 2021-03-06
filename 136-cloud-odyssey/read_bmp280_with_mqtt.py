import time

import board
import busio

import sys

sys.path.insert(0, '/home/pi/sondes/tempo2mqtt')
import adafruit_bmp280

import paho.mqtt.client as mqtt

Broker = "localhost"
pub_topic = "sensors/tempo"  # send messages to this topic

i2c = busio.I2C(board.SCL, board.SDA)
bmp280 = adafruit_bmp280.Adafruit_BMP280_I2C(i2c)

# change this to match the location's pressure (hPa) at sea level
bmp280.sea_level_pressure = 1017


#################################################"
# Common functions
#################################################"
filename = "/home/pi/136-cloud-odyssey/common_functions.py"
exec(open(filename).read())


############### MQTT section ##################

def on_connect(client, userdata, flags, rc):
    logInfo("Connected with result code " + str(rc))
    # client.subscribe(sub_topic)


client = mqtt.Client()
client.on_connect = on_connect
client.connect(Broker, 1883, 60)
client.loop_start()

############### LOOP ##################

while True:
    sensor_data = [bmp280.temperature, bmp280.pressure]
    client.publish(pub_topic, str(sensor_data))
    logDebug("Temperature : " + str(sensor_data))
    time.sleep(5)
