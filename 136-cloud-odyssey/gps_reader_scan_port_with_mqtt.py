import glob
import sys
import time

import pynmea2
import serial
import paho.mqtt.client as mqtt

Broker = "localhost"
pub_topic = "sensors/gps"  # send messages to this topic


# port = "/dev/ttyUSB3"  # the serial port to which the pi is connected.


#################################################"
# Common functions
#################################################"
filename = "/home/pi/136-cloud-odyssey/common_functions.py"
exec(open(filename).read())


def _scan_ports():
    if sys.platform.startswith('win'):
        ports = ['COM%s' % (i + 1) for i in range(256)]
    elif sys.platform.startswith('linux') or sys.platform.startswith('cygwin'):
        # this excludes your current terminal "/dev/tty"
        patterns = ('/dev/tty[A-Za-z]*', '/dev/ttyUSB*')
        ports = [glob.glob(pattern) for pattern in patterns]
        ports = [item for sublist in ports for item in sublist]  # flatten
    elif sys.platform.startswith('darwin'):
        patterns = ('/dev/*serial*', '/dev/ttyUSB*', '/dev/ttyS*')
        ports = [glob.glob(pattern) for pattern in patterns]
        ports = [item for sublist in ports for item in sublist]  # flatten
    else:
        raise EnvironmentError('Unsupported platform')
    return ports


ser = {}
serialFound = False

while True:
    try:
        try:
            while True:
                ports = _scan_ports()
                if len(ports) == 0:
                    log('No ports found, waiting 10 seconds...press Ctrl-C to quit...\n')
                    time.sleep(10)
                    continue

                try:
                    for port in ports:
                        try:
                            # try to open serial port
                            log('Trying port [' + port + "]")
                            ser = serial.Serial(port,
                                            baudrate=9600,
                                            timeout=0.5,
                                            rtscts=True,
                                            dsrdtr=True)
                            try:
                                # try to read a line of data from the serial port and parse
                                # 'warm up' with reading some input
                                for i in range(10):
                                    ser.readline()
                                # try to parse (will throw an exception if input is not valid NMEA)
                                pynmea2.parse(ser.readline().decode('utf-8', errors='replace'))
                                serialFound = True
                                continue
                            except Exception as e:
                                log('Error reading serial port ' + type(e).__name__ + "-" + str(e))
                                ser.close()
                        except Exception as e:
                            log('Error opening serial port ' + type(e).__name__ + "-" + str(e))

                    if serialFound:
                        log("Suitable serial port found !")
                        break
                except Exception as e:
                    log('Error on initialization ' + type(e).__name__ + "-" + str(e))
                    time.sleep(1)

                log('Scanned all ports, waiting 10 seconds...press Ctrl-C to quit...\n')
                time.sleep(10)
        except KeyboardInterrupt:
            log('Ctrl-C pressed, exiting port scanner\n')
            exit(1)

        while 1:
            try:
                data = ser.readline()
                break
            except:
                log("opening serial port ...")
                time.sleep(0.5)


        ############### MQTT section ##################

        def on_connect(client, userdata, flags, rc):
            log("Connected with result code " + str(rc))
            # client.subscribe(sub_topic)


        client = mqtt.Client()
        client.on_connect = on_connect
        client.connect(Broker, 1883, 60)
        client.loop_start()

        while 1:
            try:
                data = ser.readline().decode('utf-8')
                # log("data: " + str(data))
                if data[0:6] == '$GPGGA':  # the long and lat data are always contained in the GPGGA string of the NMEA data

                    nmeaobj = pynmea2.parse(data)
                    # log(nmeaobj)
                    log("num_sats:" + nmeaobj.num_sats)
                    log("position (latitude,longitude):" + str(nmeaobj.latitude) + "," + str(nmeaobj.longitude))
                    log("direction (lat_dir,lon_dir):" + nmeaobj.lat_dir + "," + nmeaobj.lon_dir)
                    log("altitude (altitude,altitude_units):" + str(nmeaobj.altitude) + " " + nmeaobj.altitude_units)
                    sensor_data = [nmeaobj.num_sats,
                                   nmeaobj.latitude,
                                   nmeaobj.longitude,
                                   nmeaobj.lat_dir,
                                   nmeaobj.lon_dir,
                                   nmeaobj.altitude,
                                   nmeaobj.altitude_units]
                    if nmeaobj.longitude != 0:
                        client.publish(pub_topic, str(sensor_data))
                    # else:
                    #     log("Mesure omise car nulle")

                    time.sleep(0.5)  # wait a little before picking the next data.
            except Exception as e:
                log(e)
                log("Closing serial...")
                ser.close()
                log("serial closed! Break loop and restart")
                break
    except Exception as e:
        log('Error on main loop ' + type(e).__name__ + "-" + str(e))
        log("wait 30s and retry from scratch ...")
        time.sleep(30)
