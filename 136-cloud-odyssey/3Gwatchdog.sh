#!/bin/bash
#
################################################################################
# Script name : 3G Watchdog 
# if connection is lost then kill concerned processes and reconfigure connection
#
# @Author : Sopra Steria Group - Team 136 Cloud Odyssey
#
################################################################################
# 

#set -x

# Include common functions
. ~/136-cloud-odyssey/common_functions.sh
# Reinitialize log file
init_log

# Start script
log "Script start"

while true
do
    sleep 300
    log "Test ping on google.com"
    ping -c 5 -I ppp0 google.com > /tmp/wvdialchecker
    RC=`grep "64 bytes from" /tmp/wvdialchecker | wc -l`
    if [ $RC -eq 0 ];
    then
        log "------------------------------"
        log "[ERROR] 3G lost"
        log "try to reconnect"
        sudo pkill curl
        sudo pkill wvdial
        sudo wvdial 3gconnect&
        sleep 90
        /home/pi/config_3G.sh &
        log "------------------------------"
    else
        log "[INFO]  google reachable"
    fi
done

log "Script end"
