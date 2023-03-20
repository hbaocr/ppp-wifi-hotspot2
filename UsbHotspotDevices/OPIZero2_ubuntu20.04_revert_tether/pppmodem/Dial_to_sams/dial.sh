

#!/bin/bash

#sudo pppd connect '/usr/sbin/chat -f /home/pi/bao/ppp.script' /dev/ttyACM0 9600 0.0.0.0:0.0.0.0 noauth local debug dump defaultroute nocrtscts persist max>
#sudo pppd 10.0.0.1:10.0.0.2 noauth local lock defaultroute debug nodetach /dev/ttyACM0 connect /home/pi/bao/client_init.sh
#sudo pppd 10.0.0.10:10.0.0.11 noauth local lock defaultroute debug nodetach /dev/ttyACM0 connect /home/ubuntu/Desktop/startppd/client_init.sh
CHAT_SCRIPT=$(pwd)/chat-with-sams-vocal.sh
DEV=/dev/ttyACM0
sudo pppd noauth local lock defaultroute debug nodetach $DEV connect $CHAT_SCRIPT