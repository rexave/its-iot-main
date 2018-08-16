#!/bin/bash

PICTUREFOLDER=/home/pi/camera/photos
LASTPICTUREFOLDER=$(ls -t $PICTUREFOLDER | head -1)
beforeLastPicture=$(ls -t $PICTUREFOLDER/$LASTPICTUREFOLDER | head -2 | tail -1)
echo $PICTUREFOLDER/$LASTPICTUREFOLDER/$beforeLastPicture

./dropbox_uploader.sh upload $PICTUREFOLDER/$LASTPICTUREFOLDER/$beforeLastPicture $beforeLastPicture