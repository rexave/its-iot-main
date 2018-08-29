#!/bin/bash
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

PICTUREFOLDER=/home/pi/camera/photos

while true
do 
	#ls -l ${PICTUREFOLDER}/image_*[0,2,4,6,8]0_*.jpg | head -n -1 | 2>&1
	#echo "test"
	# Try to send ALL unsent files until now (one out of 20) except last one which could still be written
	for filename in $(ls ${PICTUREFOLDER}/image_*[0,2,4,6,8]0_*.jpg | head -n -1) ; do
		#logDebug "Uploading : " ${filename}

		# Capture and log result
		vl_result=$(/home/pi/dropboxUploader/dropbox_uploader.sh upload ${filename} $(echo $(basename ${filename}) | sed "s/.jpg/__sent_$(date +%F"_"%H-%M-%S).jpg/") && mv ${filename} ${filename}".sent")
		vl_ret=$?
		logInfo ${vl_result} " with return code $vl_ret"
	done
	logInfo "wait betwen each loop so that there sould always be at least one file available"
	sleep 10
done

logNotice "Script end"
