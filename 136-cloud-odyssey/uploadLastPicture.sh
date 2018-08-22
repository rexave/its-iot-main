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
LASTPICTUREFOLDER=$(ls -t $PICTUREFOLDER | head -1)
beforeLastPicture=$(ls -t $PICTUREFOLDER/$LASTPICTUREFOLDER | head -2 | tail -1)
log "Uploading : " $PICTUREFOLDER/$LASTPICTUREFOLDER/$beforeLastPicture

# Capture and log result
vl_result=$(/home/pi/dropboxUploader/dropbox_uploader.sh upload $PICTUREFOLDER/$LASTPICTUREFOLDER/$beforeLastPicture $beforeLastPicture)
log ${vl_result}

log "Script end"
