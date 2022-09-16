#!/bin/bash
##########################################

echo "1. Restart mgetty services"
sudo  ./restart-mgetty-service.sh

echo "2. Route all ethernet traffic from pppx(10.9.0.x) to output ethx by iptables"
sudo  ./start-nat-iptables.sh 
