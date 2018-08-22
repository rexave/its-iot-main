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
vg_logFile=${vg_logDir}/${vg_script}".log"


################################################################################
# Utility function that adds timestamp and script name in front of 
# the content in parameters
#
# Example usage : log Script start
# Example result : 2018-08-22T17:42:01+00:00 | ./BOOT_ALL.sh | Script start
################################################################################
function log() {
	#vg_script=$0
	vl_params=$*
	echo $(date --iso-8601=seconds) "|" ${vg_script} "|" ${vl_params} 
	echo $(date --iso-8601=seconds) "|" ${vg_script} "|" ${vl_params} >> ${vg_logFile}
}

################################################################################
# Utility function to create a new log file while renaming old one
#
################################################################################
function init_log() {
	# Create folder if not exists
	if [[ ! -d ${vg_logDir} ]]
       	then
		mkdir -p ${vg_logDir}
	fi
	# Check for existing .log file
	if [[ -f ${vg_logFile} ]]
	then
		# Rename existing .log file to .log.0000 with an incremental number
		vl_num=0
		printf -v vl_seq "%04d" ${vl_num}
		while [[ -f ${vg_logFile}.${vl_seq} ]]
		do
			vl_num=$((vl_num+1))
			printf -v vl_seq "%04d" ${vl_num}
		done
		# Move original log file to the next available number
		mv ${vg_logFile} ${vg_logFile}.${vl_seq}
	fi
	# Create new .log file
	touch ${vg_logFile}
}

