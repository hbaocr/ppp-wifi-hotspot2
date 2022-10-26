#!/bin/bash
#orangepi debian buster : Orangepizero2_2.2.0_ubuntu_focal_server_linux4.9.170.7z
#https://drive.google.com/file/d/1LXvrSuMj9fP5Ldnjg1AoVe3AUbsbGWVY/view?usp=sharing

sudo ./install-facilities.sh
sudo ./setup-network-iface.sh
## in the folder ../WEBAPI
sudo ./install-web-api.sh
sudo ./setup-g_ether-gadget-service-onboot.sh

