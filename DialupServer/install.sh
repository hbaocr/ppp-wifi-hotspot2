#!/bin/bash
##########################################
# Get the Ubuntu version
ubuntu_version="$(lsb_release -r | awk '{print $2}')"

# Check if the Ubuntu version is greater than 20
if [[ "$(echo $ubuntu_version | cut -d. -f1)" -gt 20 || ("$(echo $ubuntu_version | cut -d. -f1)" -eq 20 && "$(echo $ubuntu_version | cut -d. -f2)" -gt 0) ]]
then
    echo "The Ubuntu version is greater than 20. This may not work on this OS"
    exit
else
    echo "The Ubuntu version is not greater than 20."
fi

echo "1. Install facilities"
sudo ./install-dialup-facilities.sh

echo "2. Install ppp configs"
sudo ./install-ppp-config.sh

echo "3. Install and start mgetty services"
sudo  ./install-mgetty-service.sh

echo "4. Route all ethernet traffic from pppx(10.9.0.x) to output ethx by iptables"
sudo  ./start-nat-iptables.sh 
