#!/bin/bash
#Orangepizero2_2.2.0_ubuntu_focal_server_linux4.9.170.7z
#https://drive.google.com/file/d/1LXvrSuMj9fP5Ldnjg1AoVe3AUbsbGWVY/view?usp=sharing
current_dir="$(pwd)"
chmod +x *.sh
chmod +x ./bin/ppp/ip-down
chmod +x ./bin/ppp/ip-up

cd $current_dir
sudo $current_dir/install-facilities.sh

cd $current_dir
sudo $current_dir/setup-network-iface.sh

## in the folder ../WEBAPI
cd $current_dir
sudo $current_dir/install-web-api.sh

cd $current_dir
sudo $current_dir/setup-g_ether-gadget-service-onboot.sh

#############################################
echo "Reboot service"
sudo reboot