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
	log "Kill all remaining curl processes and start a new uploadLastPicture process" 
	sudo pkill curl
	/home/pi/dropboxUploader/uploadLastPicture.sh
	sleep 30
done

log "Script end"
