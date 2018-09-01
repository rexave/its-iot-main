#!/bin/bash
#
# @Author : Sopra Steria Group - Team 136 Cloud Odyssey
#
################################################################################
# 

# Include common functions
. ~/136-cloud-odyssey/common_functions.sh

# Start script
logNotice "Script start"


while true
do
    RC=$(ps -x | grep "mqtt-data-logger.py" | grep -v grep | wc -l)
    if [ $RC -eq 0 ];
    then
        logError "mqtt-data-logger not found, relaunching it"
        python3 -u  /home/pi/mqtt-data-logger/mqtt-data-logger.py -b localhost -t sensors/tempo -t -t sensors/gps 2>&1 &
    else
        logInfo "mqtt-data-logger present"
    fi
    sleep 60
done

logNotice "Script end"
