#!/bin/bash

while true
do
    TTYPORT=$1
    echo "---->Starting PPP Daemon $TTYPORT"
    #sudo stty -F $TTYPORT -echo
    sudo mgetty $TTYPORT
    echo "*****Disconnect PPP Daemon $TTYPORT"
    sleep 1
done



