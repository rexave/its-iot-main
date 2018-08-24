#!/bin/bash
#
#################################################
# Raspberry pi : setup proxy
# This script needs root privileges
# 
# @Author A. Heiligtag
# 
################################################

# Variables


# Inner functions

######################################################################
# Setup Proxy
######################################################################
function setupProxy() {
vl_user=""
vl_password=""

echo "Please enter proxy user : "
read vl_user

echo "Please enter proxy password : "
read -s vl_password
echo

cat > /etc/apt/apt.conf.d/10proxy << EOF
Acquire::http::Proxy "http://${vl_user}:${vl_password}@ntes.proxy.corp.sopra:8080/";
Acquire::https::Proxy "http://${vl_user}:${vl_password}@ntes.proxy.corp.sopra:8080/";
EOF

cat > /etc/environment << EOF
export {http,https,ftp}_proxy="http://${vl_user}:${vl_password}@ntes.proxy.corp.sopra:8080/"
EOF
}

function unsetupProxy() {
	echo "" > /etc/apt/apt.conf.d/10proxy
	echo "" > /etc/environment
}

vl_useProxy=N

echo "Is a proxy needed ? (O/N)"
read vl_useProxy

if [[ ${vl_useProxy} == "O" ]]
then 
	setupProxy
else
	unsetupProxy
fi

