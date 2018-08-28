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
# Reinitialize log file
init_log

# Start script
log "Script start"


sudo route add default gw 10.64.64.64 || log "Error in route add default gw"
# Deletes all DNS information for this interface
(sudo resolvconf -f -d ppp0.*) || log "Error in resolvconf -d ppp0"
# Deletes all DNS information for this interface
(sudo resolvconf -f -d wwan0.*) || log "Error in resolvconf -d wwan0"
sleep 5
# Adds new DNS servers
(echo "dns-nameservers 8.8.8.8" | sudo resolvconf -a ppp0) || log "Error in resolvconf -a ppp0"
# Adds new DNS servers
(echo "dns-nameservers 8.8.8.8" | sudo resolvconf -a wwan0) || log "Error in resolvconf -a wwan0"


log "End script"
