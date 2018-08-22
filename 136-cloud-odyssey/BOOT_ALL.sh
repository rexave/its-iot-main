#!/bin/bash
#
################################################################################
# Main BOOT script
#
# @Author : Sopra Steria Group - Team 136 Cloud Odyssey
#
################################################################################
# 

# Include common functions
. ~/136-cloud-odyssey/common_functions.sh
# Reinitialize log file
init_log


init_named_log lostlines.log
# Redirect stdout ( > ) into a named pipe ( >() ) running "tee"
exec > >(tee -i ~/LOG/lostlines.log)

# Without this, only stdout would be captured - i.e. your
# log file would not contain any error messages.
# SEE (and upvote) the answer by Adam Spiers, which keeps STDERR
# as a separate stream - I did not want to steal from him by simply
# adding his answer to mine.
exec 2>&1


# Start script
log "Script start"

# Send MQTT to HTTP
if [[ 0 -eq $(mypgrep "mqtt2http.py") ]]
then
	log "No mqtt2http.py process found, relaunching"
	init_named_log mqtt2http
	python3 ~/136-cloud-odyssey/mqtt2http.py > ~/LOG/mqtt2http.log 2>&1 &
fi

# Thermometer Reader
if [[ 0 -eq $(mypgrep "read_bmp280_with_mqtt.py") ]]
then
	log "No read_bmp280_with_mqtt.py process found, relaunching"
	init_named_log read_bmp280_with_mqtt
	python3 ~/136-cloud-odyssey/read_bmp280_with_mqtt.py > ~/LOG/read_bmp280_with_mqtt.log 2>&1 &
fi

# GPS Reader
if [[ 0 -eq $(mypgrep "gps_reader_scan_port_with_mqtt.py") ]]
then
	log "No gps_reader_scan_port_with_mqtt.py process found, relaunching"
	init_named_log gps_reader_scan_port_with_mqtt
	python3 ~/136-cloud-odyssey/gps_reader_scan_port_with_mqtt.py > ~/LOG/gps_reader_scan_port_with_mqtt.log 2>&1 &
fi

# Send MQTT to Sigfox
if [[ 0 -eq $(mypgrep "mqtt2sigfox.py") ]]
then
	log "No mqtt2sigfox.py process found, relaunching"
	init_named_log mqtt2sigfox
	python3 ~/136-cloud-odyssey/mqtt2sigfox.py > ~/LOG/mqtt2sigfox.log 2>&1 &
fi

# Camera manager
if [[ 0 -eq $(mypgrep "camera_manager.py") ]]
then
	log "No camera_manager process found, relaunching"
	init_named_log camera_manager
	python3 ~/136-cloud-odyssey/camera_manager.py > ~/LOG/camera_manager.log 2>&1 &
fi

# Send MQTT to File
if [[ 0 -eq $(mypgrep "mqtt2fileLoop.sh") ]]
then
	log "No mqtt2fileLoop.sh process found, relaunching"
	#./mqtt2fileLoop.sh > ~/mqtt2fileLoop.log 2>&1 &
	~/136-cloud-odyssey/mqtt2fileLoop.sh &
fi

# Upload camera to dropbox
if [[ 0 -eq $(mypgrep "uploadDropboxLoop.sh") ]]
then
	log "No uploadDropboxLoop.sh process found, relaunching"
	#./uploadDropboxLoop.sh  > ~/uploadDropboxLoop.log 2>&1 &
	~/136-cloud-odyssey/uploadDropboxLoop.sh &
fi

# Check and reconfigure 3G network if problem
if [[ 0 -eq $(mypgrep "3Gwatchdog.sh") ]]
then
	log "No 3Gwatchdog.sh process found, relaunching"
	#./3Gwatchdog.sh > ~/3Gwatchdog.log 2>&1 &
	~/136-cloud-odyssey/3Gwatchdog.sh &
fi

# Initial configuration of 3G
log "Sleep before config 3G"
sleep 60
~/136-cloud-odyssey/config_3G.sh 

log "Script end"
