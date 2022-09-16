#!/bin/bash
##########################################

echo "1. Install facilities"
sudo ./install-dialup-facilities.sh

echo "2. Install ppp configs"
sudo ./install-ppp-config.sh

echo "3. Install and start mgetty services"
sudo  ./install-mgetty-service.sh

echo "4. Route all ethernet traffic from pppx(10.9.0.x) to output ethx by iptables"
sudo  ./start-nat-iptables.sh 
