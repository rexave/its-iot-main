#!/bin/bash

while true
do
    ps -x > /tmp/mqtt2fileWatcher
    RC=`grep "mqtt-data-logger.py" /tmp/mqtt2fileWatcher | wc -l`
    if [ $RC -eq 0 ];
    then
        echo `date` [ERROR] mqtt-data-logger not found, relaunching it
        cd /home/pi/mqtt-data-logger/
        python3 mqtt-data-logger.py -b localhost -t sensors/tempo -t -t sensors/gps > ~/mqtt-data-logger.log 2>&1 &
    else
        echo `date` [INFO] mqtt-data-logger present
    fi
    sleep 60
done