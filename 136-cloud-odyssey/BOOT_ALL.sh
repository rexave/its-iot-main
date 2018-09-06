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

# Reinitialize log file for all programs
init_named_log iot-main

# Redirect stdout ( > ) into a named pipe ( >() ) running "tee"
exec > >(tee -i ~/LOG/iot-main.log)

# Without this, only stdout would be captured - i.e. your
# log file would not contain any error messages.
# SEE (and upvote) the answer by Adam Spiers, which keeps STDERR
# as a separate stream - I did not want to steal from him by simply
# adding his answer to mine.
exec 2>&1

# Start script
logNotice "Script start - NEW SYSTEM BOOT OR PROFILE CONNECTION"

# Initial configuration of 3G
~/136-cloud-odyssey/config_3G.sh 2>&1

while true
do
	logInfo "Watchdog : checking for missing processes"

	# Send MQTT to HTTP
	if [[ 0 -eq $(mypgrep "mqtt2http.py") ]]
	then
		logInfo "No mqtt2http.py process found, relaunching"
		python3 -u ~/136-cloud-odyssey/mqtt2http.py 2>&1 &
	fi

	# Thermometer Reader
	if [[ 0 -eq $(mypgrep "read_bmp280_with_mqtt.py") ]]
	then
		logInfo "No read_bmp280_with_mqtt.py process found, relaunching"
		python3 -u ~/136-cloud-odyssey/read_bmp280_with_mqtt.py 2>&1 &
	fi

	# GPS Reader
	if [[ 0 -eq $(mypgrep "gps_reader_scan_port_with_mqtt.py") ]]
	then
		logInfo "No gps_reader_scan_port_with_mqtt.py process found, relaunching"
		python3 -u ~/136-cloud-odyssey/gps_reader_scan_port_with_mqtt.py 2>&1 &
	fi

	# Send MQTT to Sigfox
	if [[ 0 -eq $(mypgrep "mqtt2sigfox.py") ]]
	then
		logInfo "No mqtt2sigfox.py process found, relaunching"
		python3 -u ~/136-cloud-odyssey/mqtt2sigfox.py 2>&1 &
	fi

	# Camera manager
	if [[ 0 -eq $(mypgrep "camera_manager.py") ]]
	then
		logInfo "No camera_manager process found, relaunching"
		python3 -u ~/136-cloud-odyssey/camera_manager.py 2>&1 &
	fi

	# Send MQTT to File
	if [[ 0 -eq $(mypgrep "mqtt2fileLoop.sh") ]]
	then
		logInfo "No mqtt2fileLoop.sh process found, relaunching"
		~/136-cloud-odyssey/mqtt2fileLoop.sh 2>&1 &
	fi

	# Upload camera to dropbox
	if [[ 0 -eq $(mypgrep "uploadPictures.sh") ]]
	then
		logInfo "No uploadPictures.sh process found, relaunching"
		~/136-cloud-odyssey/uploadPictures.sh 2>&1 &
	fi

	# Check and reconfigure 3G network if problem
	if [[ 0 -eq $(mypgrep "3Gwatchdog.sh") ]]
	then
		logInfo "No 3Gwatchdog.sh process found, relaunching"
		~/136-cloud-odyssey/3Gwatchdog.sh 2>&1 &
	fi

	sleep 300
done

logNotice "Script end"

