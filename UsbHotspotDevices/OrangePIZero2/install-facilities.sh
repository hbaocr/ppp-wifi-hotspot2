#!/bin/bash
#orangepi debian buster : Orangepizero2_2.2.0_debian_buster_desktop_linux4.9.170.7z
#https://drive.google.com/file/d/1aTNyzHfoh_EehlEc7t1IUmlwO9-1h4mH/view?usp=sharing

setup_path="$(pwd)"

##########################################
echo "1. Install required services"
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y hostapd dnsmasq ppp minicom iptables python3 psmisc wget
# if need Wifi AP
# sudo apt-get install -y hostapd 
#################use legacy iptables#########################
echo '---> Please select the legacy option of iptables: (1) iptables-legacy'
sudo update-alternatives --config iptables


###install nvm and nodejs
#wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
#source ~/.bashrc
#nvm install 14
#install nodejs
echo '---> Install nodejs 14. Require >= armv7'
curl -sL https://deb.nodesource.com/setup_14.x | bash -
apt-get install -y nodejs


