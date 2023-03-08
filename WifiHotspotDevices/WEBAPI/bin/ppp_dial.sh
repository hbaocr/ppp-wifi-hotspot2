#!/bin/bash

MODEM_TYPE=$1
NUMBER=$2
BAUD=$3
DEVICE=$4

MODEM_TYPE=${MODEM_TYPE:-1}
NUMBER=${NUMBER:-8000}
BAUD=${BAUD:-115200}
DEVICE=${DEVICE:-ttyACM0}
DEV=/dev/$DEVICE
if [ $MODEM_TYPE -gt 0 ]
then
    echo "Dial to Hardware 56k modem. Dial Number $NUMBER"
    CHAT_SCRIPT=$(pwd)/chatscript56kmodem
    CHAT_DISCONNECT_SCRIPT=$(pwd)/chatscript56khangup
else
    echo "Dial to SAMS VOCAL SOFTWARE MODEM. Dial Number $NUMBER"
    CHAT_SCRIPT=$(pwd)/chatscriptsamsmodem
    CHAT_DISCONNECT_SCRIPT=$(pwd)/chatscript56khangup
fi


CHAT_EXE=$(which chat)
PPPD_EXE=$(sudo which pppd)
PERSIST_PPD="persist maxfail 10 holdoff 10"
#Enables the "passive" option in the LCP. With this option, pppd will attempt to initiate a connection; if no reply is received from the peer, pppd will then just wait passively for a valid LCP packet from the peer, instead of exiting, as it would without this option.
PASSIVE=""
sudo $PPPD_EXE $PERSIST_PPD $PASSIVE lock noauth local defaultroute replacedefaultroute debug nodetach $DEV $BAUD \
connect "$CHAT_EXE -v -T$NUMBER -f $CHAT_SCRIPT" \
disconnect "$CHAT_EXE -v -f $CHAT_DISCONNECT_SCRIPT" #>> "/var/tmp/pppd.log"
