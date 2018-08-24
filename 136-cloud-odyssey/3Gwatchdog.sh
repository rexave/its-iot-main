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
    log "Current default route is $(route | grep '^default' | grep -o '[^ ]*$') : $(ip route ls)"
    if [[ 0 -eq $(ping -c 5 -I ppp0 google.com | grep "bytes from" | wc -l 2>/dev/null) ]]
    then
        log "[ERROR] Connection to google lost - hoping for automatic reconnect."
	log $(nmcli)
        sleep 90
    else
        log "[INFO] google reachable"
    fi

    sleep 300
done

log "Script end"
