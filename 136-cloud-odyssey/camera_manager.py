#!/usr/bin/python
import os
import time

import paho.mqtt.client as mqtt

from picamera import PiCamera

#################################################"
# Common functions
#################################################"
filename = "/home/pi/136-cloud-odyssey/common_functions.py"
exec(open(filename).read())

logNotice("Script start")

#################################################"
# Global variables
#################################################"
dir_home = "/home/pi/camera/photos/"  # with trailing slash !
frequence = 5  # in seconds

camera = PiCamera()
camera.resolution = (2592, 1944)
camera.exposure_mode = 'antishake'
camera.flash_mode = 'off'
camera.rotation = 180

# Create directory if not existing
logInfo("creating directory " + str(dir_home))
try:
    os.stat(dir_home)
except:
    os.mkdir(dir_home) 

# Start all sequences at 1
i = 1

file_list = os.listdir(dir_home)
if not file_list:
    latest_file = ""
else:
    latest_file = max(file_list, key=lambda x:x[:+13])
    i = int(latest_file[6:12]) + 1

logDebug("Info i = " + str(i) + " last file :" + latest_file[6:12])

# Check if enough free space on SD Card
def check_free_storage():
    statvfs = os.statvfs("/home/pi")
    Gb_free_on_storage = statvfs.f_bsize * statvfs.f_bavail / 1024 / 1024 / 1024
    if Gb_free_on_storage < 2:
        logWarning("insufficent free storage : " + str(Gb_free_on_storage) + " Gb")
        logError("exiting to protect the system")
        exit(0)

logInfo("Begin loop")

# Main loop
while True:
    time.sleep(frequence)

    # Change timestamp for each photo
    current_time = time.localtime(time.time())
    # Year-Month-Day_Hour-Minutes-Seconds
    file_name = (str(current_time[0]) + "-" + str(current_time[1]).zfill(2) + "-" + str(current_time[2]).zfill(2) + "_" +
            str(current_time[3]).zfill(2) + "-" + str(current_time[4]).zfill(2) + "-" + str(current_time[5]).zfill(2) )

    try: 
        camera.capture(dir_home + '/image_%06d_' %i + file_name + '.jpg')
        logDebug("Photo saved " + dir_home + '/image_%06d_' %i + file_name + '.jpg')
    except Exception as e:
        logError(e)
        continue
	
    if i % 10 == 0:
        check_free_storage()

    i += 1

