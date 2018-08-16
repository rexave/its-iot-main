#!/bin/bash

while true
do
    sleep 300
    ping -c 5 -I ppp0 google.com > /tmp/wvdialchecker
    RC=`grep "64 bytes from" /tmp/wvdialchecker | wc -l`
    if [ $RC -eq 0 ];
    then
        echo ------------------------------
        echo `date` [ERROR] 3G lost
        echo try to reconnect
        sudo pkill curl
        sudo pkill wvdial
        sudo wvdial 3gconnect&
        sleep 90
        /home/pi/config_3G.sh &
        echo ------------------------------
    else
        echo `date` [INFO]  google reachable
    fi
done