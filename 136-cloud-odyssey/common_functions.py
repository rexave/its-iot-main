#!/usr/bin/python
import os
import time

#################################################"
# Functions
#################################################"
def log(message):
    current_time = time.localtime(time.time())
    timestamp = (str(current_time[0]) + "-" + str(current_time[1]) + "-" + str(current_time[2]) + " | " +
                str(current_time[3]) + "-" + str(current_time[4]) + "-" + str(current_time[5]))
    print(timestamp + " | " + os.path.basename(__file__) + " | " + message)



