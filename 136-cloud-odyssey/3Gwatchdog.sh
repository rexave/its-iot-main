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

# Start script
logNotice "Script start"

while true
do
    logInfo "Current default route is $(route | grep '^default' | grep -o '[^ ]*$') : $(ip route ls)"
    if [[ 0 -eq $((ping -c 5 -I ppp0 google.com | grep "bytes from" | wc -l) 2>/dev/null) ]]
    then
        logError "Connection to google lost - hoping for automatic reconnect."
	logDebug $(nmcli)
        sleep 90
    else
        logInfo "Google reachable"
    fi

    sleep 300
done

logNotice "Script end"
