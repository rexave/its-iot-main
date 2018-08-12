#!/usr/bin/python
import ast
import struct
import sys
import time

import paho.mqtt.client as mqtt
import serial

sigfoxModemPort = '/dev/ttyAMA0'

Broker = "localhost"
topic_temp = "sensors/tempo"
topic_gps = "sensors/gps"

last_gps = {}
last_temp = {}


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
    if topic == topic_temp:
        # print("updating last_temp [" + str(last_temp) + "} ")
        last_temp = message
        # print("new last_temp [" + str(last_temp) + "} ")

    elif topic == topic_gps:
        # print("updating last_gps [" + str(last_gps) + "} ")
        last_gps = message
        # print("new last_gps [" + str(last_gps) + "} ")


client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message
client.connect(Broker, 1883, 60)
client.subscribe(topic_temp)
client.subscribe(topic_gps)
client.loop_start()


### sigfox flavor

# Low level
def transfert(send, true, false):
    # Add suffix
    send += "\r"
    true += "\r\n"
    false += "\r\n"
    # Send data
    serialFd.write(bytes(send, 'UTF-8'))
    # Wait for response
    data = ''
    first = 1
    while true not in data and false not in data:
        c = serialFd.readline().decode('utf-8', errors='replace')
        if c == '':
            return ''
        elif first == 1:  # remove useless \r\n before reply
            if c != "\r" and c != "\n":
                first = 0
                data = c
        else:
            data += c

    if false in data:
        data = ''
    else:
        data = data.replace("\r\n\r\n", "\r\n")

    return data


# Commands
def sendMsg(msg):
    print('Sending message...')
    if transfert("AT$SS={0}\r".format(msg), 'OK', 'ERROR'):
        print('OK!')
        return 0
    else:
        sys.stderr.write('Sending failed!\n')
        return 1


def returnTemperature():
    print('Request temperature...')
    data = transfert('ATI26', 'OK', 'ERROR')
    if data == '':
        sys.stderr.write('ERROR: No reply!\n')
        return 1
    else:
        lists = data.split("\r\n");
        print
        '{}C'.format(lists.pop(0))
        return 0


def float_to_hex(f):
    return hex(struct.unpack('<I', struct.pack('<f', f))[0])


# latitude::float:32 longitude::float:32 temperature::int:8 altitude::uint:16
def createMessage(gps, temp):
    # gps = ['03', 47.216233, -1.549436, 'N', 'W', 57.4, 'M']
    # nbSatelites = ast.literal_eval(gps)[0]
    latitude = ast.literal_eval(gps)[1]
    longitude = ast.literal_eval(gps)[2]
    # direction_latitude = ast.literal_eval(gps)[3]
    # direction_longitude = ast.literal_eval(gps)[4]
    altitude = ast.literal_eval(gps)[5]
    # altitudeUnit = ast.literal_eval(gps)[6]

    temperature = ast.literal_eval(temp)[0]

    latitude_hexa = float_to_hex(latitude)
    longitude_hexa = float_to_hex(longitude)

    temperature_hexa = hex(int(temperature) & (2 ** 8 - 1))
    altitude_hexa = "{0:#0{1}x}".format(abs(int(altitude)), 6)  # 4 caracteres avec 0 padding

    message_hexa = str(latitude_hexa)[2:] + str(longitude_hexa)[2:] + str(temperature_hexa)[2:] + str(altitude_hexa)[2:]
    message_hexa_coupe_tous_les2_caracteres = [message_hexa[i:i + 2] for i in range(0, len(message_hexa), 2)]
    message_string = ' '.join(message_hexa_coupe_tous_les2_caracteres)
    return message_string.upper()


# last_gps = "['05', 47.216233, -1.549436, 'N', 'W', 24.4, 'M']"
# last_gps = "['03', 47.216233, -1.549436, 'N', 'W', -1.2, 'M']"
# last_temp = "[28.4783203125, 1016.4662189272158]"


while True:
    time.sleep(15 * 60)
    if last_gps == {}:
        print("No GPS data to send, will try next loop")
        continue
    print("Sending data")
    message = createMessage(last_gps, last_temp)
    print("data : " + message)

    message2 = "42 3c e8 ff bf d0 17 87 CC D0 1C"
    print("message2 : " + message2)

    # exit(0)

    # Initialisation
    try:
        serialFd = serial.Serial(
            port=sigfoxModemPort,
            timeout=10,
            baudrate=9600,
            bytesize=serial.EIGHTBITS,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE,
            xonxoff=False,
            rtscts=False
        )
    except serial.SerialException as e:
        sys.stderr.write("Open device {} failed :\n\t{}\n".format(sigfoxModemPort, e))
        sys.exit(1)

    # Test modem presence & echo disabling
    if not transfert('ATE0', 'OK', 'ERROR'):
        sys.stderr.write(' ERROR: No reply\n')
        serialFd.close()

    ret = sendMsg(message)

    serialFd.close()
