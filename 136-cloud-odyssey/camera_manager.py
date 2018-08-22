#!/usr/bin/python
import os
import time

import paho.mqtt.client as mqtt

from picamera import PiCamera


# Global variables
dir_home = "/home/pi/camera/photos/"  # with trailing slash !
frequence = 5  # in seconds

camera = PiCamera()
camera.resolution = (2592, 1944)


# Prepare timestamp for file names
current_time = time.localtime(time.time())
file_name = (str(current_time[0]) + "-" + str(current_time[1]) + "-" + str(current_time[2]) + "_" +
            str(current_time[3]) + "-" + str(current_time[4]) + "-" + str(current_time[5]))

# Create directory if not existing
print("creating directory " + str(dir_home))
try:
    os.stat(dir_home)
except:
    os.mkdir(dir_home) 

# Start all sequences at 1
i = 1

# Check if enough free space on SD Card
def check_free_storage():
    statvfs = os.statvfs("/home/pi")
    Gb_free_on_storage = statvfs.f_bsize * statvfs.f_bavail / 1024 / 1024 / 1024
    if Gb_free_on_storage < 2:
        print("insufficent free storage : " + str(Gb_free_on_storage) + " Gb")
        print("exiting to protect the system")
        exit(0)


# Main loop
while True:
    time.sleep(frequence)
    camera.capture(dir_home + '/image_' + file_name + '_%05d.jpg' % i)

    if i % 10 == 0:
        check_free_storage()

    i += 1
