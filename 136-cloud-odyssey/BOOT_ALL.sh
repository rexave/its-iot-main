#!/bin/bash
#
################################################################################
# Main BOOT script
#
# @Author : Sopra Steria Group - Team 136 Cloud Odyssey
#
################################################################################
# 

# Redirect stdout ( > ) into a named pipe ( >() ) running "tee"
exec > >(tee -i ~/lostlines.log)

# Without this, only stdout would be captured - i.e. your
# log file would not contain any error messages.
# SEE (and upvote) the answer by Adam Spiers, which keeps STDERR
# as a separate stream - I did not want to steal from him by simply
# adding his answer to mine.
exec 2>&1


# Include common functions
. ~/136-cloud-odyssey/common_functions.sh
# Reinitialize log file
init_log

# Start script
log "Script start"

# If there is no python3 at all, start everything ?
if ! pgrep -x "python3" > /dev/null
then
	log "Restarting everything"
	#set -x
	python3 mqtt2http/mqtt2http.py > ~/mqtt2http.log 2>&1 &
	python3 sondes/tempo2mqtt/read_bmp280_with_mqtt.py > ~/read_bmp280_with_mqtt.log 2>&1 &
	python3 sondes/gps/gps_reader_scan_port_with_mqtt.py > ~/gps_reader_scan_port_with_mqtt.log 2>&1 &
	python3 mqtt2sigfox/mqtt2sigfox.py > ~/mqtt2sigfox.log 2>&1 &
	python3 camera/camera_manager.py > ~/camera_manager.log 2>&1 &
	#./mqtt2fileLoop.sh > ~/mqtt2fileLoop.log 2>&1 &
	~/136-cloud-odyssey/mqtt2fileLoop.sh &
	#./uploadDropboxLoop.sh  > ~/uploadDropboxLoop.log 2>&1 &
	~/136-cloud-odyssey/uploadDropboxLoop.sh &
	#./3Gwatchdog.sh > ~/3Gwatchdog.log 2>&1 &
	~/136-cloud-odyssey/3Gwatchdog.sh &
	#set +x
fi

# Initial configuration of 3G
log "Sleep before config 3G"
sleep 60
~/136-cloud-odyssey/config_3G.sh 

log "Script end"
