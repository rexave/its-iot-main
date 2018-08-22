if ! pgrep -x "python3" > /dev/null
then
        python3 mqtt2http/mqtt2http.py > ~/mqtt2http.log 2>&1 &
        python3 sondes/tempo2mqtt/read_bmp280_with_mqtt.py > ~/read_bmp280_with_mqtt.log 2>&1 &
        python3 sondes/gps/gps_reader_scan_port_with_mqtt.py > ~/gps_reader_scan_port_with_mqtt.log 2>&1 &
        python3 mqtt2sigfox/mqtt2sigfox.py > ~/mqtt2sigfox.log 2>&1 &
        python3 camera/camera_manager.py > ~/camera_manager.log 2>&1 &
        ./mqtt2fileLoop.sh > ~/mqtt2fileLoop.log 2>&1 &
        ./uploadDropboxLoop.sh  > ~/uploadDropboxLoop.log 2>&1 &
        ./3Gwatchdog.sh > ~/3Gwatchdog.log 2>&1 &
fi
sleep 60
./config_3G.sh