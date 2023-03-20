#!/bin/bash
CHAT_SCRIPT=$(pwd)/chat-script-to-56kmodem
DEV=/dev/ttyACM0
BAUD=9600
NUMBER=1089
sudo pppd noauth local lock replacedefaultroute debug nodetach $DEV $BAUD  connect "/usr/sbin/chat -v -T$NUMBER -f $CHAT_SCRIPT"
