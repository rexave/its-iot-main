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

PICTUREFOLDER=/home/pi/camera/photos

while true
do 
	# Try to send ALL unsent files until now (one out of 20)
	for filename in $(ls -tr $PICTUREFOLDER/*[0,2,4,6,8]0.jpg 2>/dev/null) ; do
		#log "Uploading : " ${filename}

		# Capture and log result
		vl_result=$(/home/pi/dropboxUploader/dropbox_uploader.sh upload ${filename} $(echo $(basename ${filename}) | sed "s/.jpg/__sent_$(date +%F"_"%H-%M-%S).jpg/") && mv ${filename} ${filename}".sent")
		vl_ret=$?
		log ${vl_result} " with return code $vl_ret"
	done
	# wait betwen each loop so that there sould always be at least one file available
	sleep 10
done

log "Script end"
