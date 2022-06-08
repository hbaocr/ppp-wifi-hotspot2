#!/bin/bash
# THis script run when boot up  by systemd service defined by "config_service/autohotspot.service" to let  PI work as AP
#wifidev="wlan0"
# sleep sometime to let system more stable
sleep 2

echo "===> Start Wifi Access Point Service"

# & ==> fork to new process to run AP
sudo ./start_fork_ap.sh &
