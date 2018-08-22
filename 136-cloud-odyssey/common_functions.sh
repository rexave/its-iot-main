#!/bin/bash
#
################################################################################
# Common functions for IoT-Main 
#
# @Author : Sopra Steria Group - Team 136 Cloud Odyssey
#
################################################################################
#

# Global variables - NOT exported to only work in calling script
vg_logDir=~/LOG
vg_script=$(basename $0)

################################################################################
# Utility function that adds timestamp and script name in front of 
# the content in parameters
#
# Example usage : log Script start
# Example result : 2018-08-22T17:42:01+00:00 | ./BOOT_ALL.sh | Script start
################################################################################
function log() {
	vl_params=$*
	vl_date=$(date +%F" | "%X) 
	vl_logFile=${vg_logDir}/${vg_script}".log"

	#echo ${vl_date} "|" ${vg_script} "|" ${vl_params} 
	echo ${vl_date} "|" ${vg_script} "|" ${vl_params} >> ${vl_logFile}
}

################################################################################
# Utility function to create a new log file with a specific name while renaming old file
#
################################################################################
function init_named_log() {
	vl_name=$1
	vl_namedLogFile=${vg_logDir}/${vl_name}".log"
	# Create folder if not exists
	if [[ ! -d ${vg_logDir} ]]
       	then
		mkdir -p ${vg_logDir}
	fi
	# Check for existing .log file
	if [[ -f ${vl_namedLogFile} ]]
	then
		# Rename existing .log file to .log.0000 with an incremental number
		vl_num=0
		printf -v vl_seq "%04d" ${vl_num}
		while [[ -f ${vl_namedLogFile}.${vl_seq} ]]
		do
			vl_num=$((vl_num+1))
			printf -v vl_seq "%04d" ${vl_num}
		done
		# Move original log file to the next available number
		mv ${vl_namedLogFile} ${vl_namedLogFile}.${vl_seq}
	fi
	# Create new .log file
	touch ${vl_namedLogFile}
}

################################################################################
# Utility function to create a new log file for current script while renaming old file
#
################################################################################
function init_log() {
	init_named_log ${vg_script}
}

function mypgrep() {
	echo $(ps -ef | grep $* | grep -v grep | wc -l)
}

