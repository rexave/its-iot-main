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

# Try to send ALL unsent files until now
for filename in $(ls -t $PICTUREFOLDER/*.jpg &2>/dev/null) ; do
	log "Uploading : " ${filename}

	# Capture and log result
	vl_result=$(/home/pi/dropboxUploader/dropbox_uploader.sh upload ${filename} $(basename ${filename}) && mv ${filename} ${filename}".sent")
	vl_ret=$?
	log ${vl_result} " with return code $vl_ret"
done

log "Script end"
