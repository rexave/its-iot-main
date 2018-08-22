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
beforeLastPicture=$(ls -t $PICTUREFOLDER/*.jpg | head -2 | tail -1)
log "Uploading : " ${beforeLastPicture}

# Capture and log result
vl_result=$(/home/pi/dropboxUploader/dropbox_uploader.sh upload ${beforeLastPicture} $(basename ${beforeLastPicture}) && mv ${beforeLastPicture} ${beforeLastPicture}".sent")
vl_ret=$?
log ${vl_result} " with return code $vl_ret

log "Script end"
