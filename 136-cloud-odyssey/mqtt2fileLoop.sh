#!/bin/bash
#
# @Author : Sopra Steria Group - Team 136 Cloud Odyssey
#
################################################################################
# 

# Include common functions
. ~/136-cloud-odyssey/common_functions.sh
# Reinitialize log file
init_log

# Start script
log "Script start"


while true
do
    ps -x > /tmp/mqtt2fileWatcher
    RC=`grep "mqtt-data-logger.py" /tmp/mqtt2fileWatcher | wc -l`
    if [ $RC -eq 0 ];
    then
        log "[ERROR] mqtt-data-logger not found, relaunching it"
        cd /home/pi/mqtt-data-logger/
        python3 -u mqtt-data-logger.py -b localhost -t sensors/tempo -t -t sensors/gps > ~/LOG/mqtt-data-logger.log 2>&1 &
    else
        log "[INFO] mqtt-data-logger present"
    fi
    sleep 60
done

log "Script end"
