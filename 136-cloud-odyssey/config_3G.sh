#!/bin/bash
# 
################################################################################
# Resets network configuration to force Google DNS servers
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

# Delete home ethernet route if exists
sudo route del -net 0.0.0.0 gw 192.168.0.1 netmask 0.0.0.0 eth0 2>/dev/null
# Delete Sopra routes if exists
sudo route del -net 0.0.0.0 gw  172.22.0.1  netmask 0.0.0.0 eth0 2>/dev/null
sudo route del -net 172.22.0.0 gw  0.0.0.0  netmask 255.255.0.0  eth0 2>/dev/null
sudo route del -net 172.17.15.52  gw   172.22.0.1   netmask 255.255.255.255 eth0 2>/dev/null

#sudo route add default gw 10.64.64.64 ppp0 || logError "Error in route add default gw"

logNotice "End script"
