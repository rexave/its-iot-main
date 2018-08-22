#!/bin/bash
# 
# Resets network configuration to force Google DNS servers
# 

sudo route add default gw 10.64.64.64
# Deletes all DNS information for this interface
sudo resolvconf -f -d ppp0.*
# Deletes all DNS information for this interface
sudo resolvconf -f -d wwan0.*
# Adds new DNS servers
echo "dns-nameservers 8.8.8.8" | sudo resolvconf -a ppp0
# Adds new DNS servers
echo "dns-nameservers 8.8.8.8" | sudo resolvconf -a wwan0

