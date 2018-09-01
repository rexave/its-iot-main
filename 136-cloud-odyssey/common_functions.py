#!/usr/bin/python
import os
import time

#################################################"
# Functions
#################################################"
def log(level, message):
    current_time = time.localtime(time.time())
    # Year-Month-Day | Hour:Minutes:Seconds
    timestamp = (str(current_time[0]) + "-" + str(current_time[1]).zfill(2) + "-" + str(current_time[2]).zfill(2) + " | " +
                str(current_time[3]).zfill(2) + ":" + str(current_time[4]).zfill(2) + ":" + str(current_time[5]).zfill(2) )
    print(timestamp + " | " + os.path.basename(__file__)  + " | " + level + " | " + message)


def logDebug(message):
    log("DEBUG", message)

def logInfo(message):
    log("INFO", message)

def logNotice(message):
    log("NOTICE", message)

def logWarning(message):
    log("WARNING", message)

def logError(message):
    log("ERROR", message)

