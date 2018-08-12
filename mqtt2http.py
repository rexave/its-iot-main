import time
import json
import urllib.request
import ast
import paho.mqtt.client as mqtt

Broker = "localhost"
topic_temp = "sensors/tempo"
topic_gps = "sensors/gps"

http_server = "https://your_server/"  # with trailing slash
node_id = 1  # MAIN = 1

last_gps = {}
last_temp = {}


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
        print("new last_temp [" + str(last_temp) + "} ")

    elif topic == topic_gps:
        # print("updating last_gps [" + str(last_gps) + "} ")
        last_gps = message
        print("new last_gps [" + str(last_gps) + "} ")


client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message
client.connect(Broker, 1883, 60)
client.subscribe(topic_temp)
client.subscribe(topic_gps)
client.loop_start()


# http request

def sendTemperature():
    if last_temp != {}:
        data = {
            'temperature': str(ast.literal_eval(last_temp)[0]),
            'pression': str(ast.literal_eval(last_temp)[1])
        }

        req = urllib.request.Request(http_server + 'temperature/' + str(node_id))
        req.add_header('Content-Type', 'application/json; charset=utf-8')
        jsondata = json.dumps(data)
        print(jsondata)
        jsondataasbytes = jsondata.encode('utf-8')  # needs to be bytes
        req.add_header('Content-Length', len(jsondataasbytes))
        response = urllib.request.urlopen(req, jsondataasbytes)
    else:
        print("no temp data : skip this loop")


def sendlocalization():
    try:
        print("sending localisation " + last_gps)
        if last_gps != {}:
            # ['05', 47.216233, -1.549436, 'N', 'W', 50.7, 'M']
            data = {
                'latitude': str(ast.literal_eval(last_gps)[1]),
                'longitude': str(ast.literal_eval(last_gps)[2]),
                'altitude': str(ast.literal_eval(last_gps)[5]),
                'satelites': str(ast.literal_eval(last_gps)[0]),
                'longitude_direction': str(ast.literal_eval(last_gps)[3]),
                'altitude_direction': str(ast.literal_eval(last_gps)[4])
            }

            req = urllib.request.Request(http_server + 'localisation/' + str(node_id))
            req.add_header('Content-Type', 'application/json; charset=utf-8')
            jsondata = json.dumps(data)
            print(jsondata)
            jsondataasbytes = jsondata.encode('utf-8')  # needs to be bytes
            req.add_header('Content-Length', len(jsondataasbytes))
            response = urllib.request.urlopen(req, jsondataasbytes)
        else:
            print("no gps data : skip this loop")
    except Exception as e:
        print('Error while sending localisation data ' + type(e).__name__ + "-" + str(e))



i = 0
while True:
    time.sleep(1 * 10)
    print("Sending data")
    try:
        sendlocalization()
        i += 1
        if i > 6:
            sendTemperature()
            i = 0

    except Exception as e:
        print('Error while sending data ' + type(e).__name__ + "-" + str(e))
        print('wait 1min before retry')
        time.sleep(1 * 60)
