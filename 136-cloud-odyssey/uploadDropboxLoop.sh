#!/bin/bash

while true
do
    sudo pkill curl
    /home/pi/dropboxUploader/uploadLastPicture.sh
    sleep 30
done