#!/bin/bash
#orangepi debian buster : Orangepizero2_2.2.0_ubuntu_focal_server_linux4.9.170.7z
#https://drive.google.com/file/d/1LXvrSuMj9fP5Ldnjg1AoVe3AUbsbGWVY/view?usp=sharing

setup_path="$(pwd)"

##########################################
echo "1. Install required services"
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y dnsmasq ppp minicom iptables python3 psmisc wget

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

################Config dnsmaq#############
# don't  let it done  auto
# stop  current running instance
sudo systemctl stop dnsmasq.service
# disable restart service
sudo systemctl disable dnsmasq.service 

# disable systemd-resolved to release port 53 for dnsmasq
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
sudo systemctl mask systemd-resolved
#To undo what you did:
# sudo systemctl unmask systemd-resolved
# sudo systemctl enable systemd-resolved
# sudo systemctl start systemd-resolved

sudo cp -f "$setup_path/config_ap/dnsmasq.conf" /etc/dnsmasq.conf

sudo systemctl enable dnsmasq.service 
sudo systemctl restart dnsmasq.service 


