#!/bin/bash

#######################################################
echo "Generate Mgetty config"
sudo  ./mgetty-config/mgetty-config-generator.sh
sudo ./mgetty-config/mgetty-login-config-generator.sh

#######################################################
echo "Generate and start Mgetty service on tntb0-7 port"
sudo ./mgetty-config/mgetty-service-config-generator.sh


