#!/usr/bin/python
import ast
import struct
import sys
import time

import paho.mqtt.client as mqtt
import serial

sigfoxModemPort = '/dev/ttyAMA0'

# CONSTANTES : Maximum un envoi toutes les 10 minutes avec Sigfox
dureeSleepApresOK = 10
dureeSleepApresProbleme = 1

# Broker = "192.168.0.165"
Broker = "localhost"
topic_temp = "sensors/tempo"
topic_gps = "sensors/gps"

last_gps = {}
last_temp = {}


#################################################"
# Common functions
#################################################"
filename = "/home/pi/136-cloud-odyssey/common_functions.py"
exec(open(filename).read())


#### MQTT flavor

def on_connect(client, userdata, flags, rc):
    logInfo("Connected with result code " + str(rc))
    # client.subscribe(sub_topic)


def on_message(client, userdata, msg):
    global last_gps
    global last_temp
    # logDebug("recieved  " + str(msg))

    topic = msg.topic
    message = str(msg.payload.decode("utf-8", "ignore"))
    if topic == topic_temp:
        # logDebug("updating last_temp [" + str(last_temp) + "} ")
        last_temp = message
        # logDebug("new last_temp [" + str(last_temp) + "} ")

    elif topic == topic_gps:
        # logDebug("updating last_gps [" + str(last_gps) + "} ")
        last_gps = message
        # logDebug("new last_gps [" + str(last_gps) + "} ")

logNotice("Program start")

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
    logInfo('Start sending message...')
    if transfert("AT$SS={0}\r".format(msg), 'OK', 'ERROR'):
        logInfo('End sending message : OK!')
        return 0
    else:
        #sys.stderr.write('Sending failed!\n')
        logError('Sending failed!')
        return 1


def float_to_hex(f):
    return hex(struct.unpack('<I', struct.pack('<f', f))[0])


# latitude::float:32 longitude::float:32 temperature::int:8 altitude::uint:16
def createMessage(gps, temp):
    logInfo("Start encoding data : gps=" + gps + ", temp=" + temp)
    # gps = ['03', 47.214291, -1.5702985, 'N', 'W', 57.4, 'M']
    # nbSatelites = ast.literal_eval(gps)[0]
    latitude = ast.literal_eval(gps)[1]
    longitude = ast.literal_eval(gps)[2]
    # direction_latitude = ast.literal_eval(gps)[3]
    # direction_longitude = ast.literal_eval(gps)[4]
    altitude = ast.literal_eval(gps)[5]
    # altitudeUnit = ast.literal_eval(gps)[6]

    temperature = ast.literal_eval(temp)[0]
    pression = ast.literal_eval(temp)[1]

    latitude_hexa = float_to_hex(latitude)
    longitude_hexa = float_to_hex(longitude)

    temperature_hexa = hex(int(temperature) & (2 ** 8 - 1))

    pression_compress = int(int(pression)/5) # pression divisé 5 pour tenir sur 1 octet
    pression_hexa = "{0:#0{1}x}".format(abs(pression_compress), 4)  # format 0x00 soit 2 caracteres de charge utile avec 0 padding

    altitude_hexa = "{0:#0{1}x}".format(abs(int(altitude)), 6)  # format 0x0000 soit 4 caracteres de charge utile avec 0 padding

    message_hexa = str(latitude_hexa)[2:] + str(longitude_hexa)[2:] + str(temperature_hexa)[2:] + str(altitude_hexa)[2:] + str(pression_hexa)[2:] # On ignore les 2 premiers caractères correspondant a 0x

    message_hexa_coupe_tous_les2_caracteres = [message_hexa[i:i + 2] for i in range(0, len(message_hexa), 2)]
    message_string = ' '.join(message_hexa_coupe_tous_les2_caracteres)
    logDebug("Encoded data : hexa=" + message_hexa + ", string=" + message_string + ", pression_compress=" + str(pression_compress))
    return message_string.upper()


# last_gps = "['05', 47.21379983333333, -1.5690243333333334, 'N', 'W', 24.4, 'M']"
# last_gps = "['03', 47.214161, -1.5687033333333333, 'N', 'W', -1.2, 'M']"
# last_temp = "[28.4783203125, 1016.4662189272158]"


while True:
    if last_gps == {}:
        logNotice("No GPS data to send, will try next loop in a few seconds")
        # Sleep court si on n'a rien envoyé
        time.sleep(dureeSleepApresProbleme * 60)
        continue
    message = createMessage(last_gps, last_temp)

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
        logError("Open device {} failed :\n\t{}\n".format(sigfoxModemPort, e))
        # Sleep court avant nouvel essai : peut-être un problème lié au froid ?
        time.sleep(dureeSleepApresProbleme * 60)
        continue
        #sys.exit(1)

    # Test modem presence & echo disabling
    if not transfert('ATE0', 'OK', 'ERROR'):
        logError('No reply\n')
        serialFd.close()

    ret = sendMsg(message)

    serialFd.close()
    # Sleep long minutes en cas de OK pour respecter le nombre maximum d'envois autorisés par jour
    time.sleep(dureeSleepApresOK * 60)
    
