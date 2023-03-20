#!/bin/bash

COUNTER=1
log_file=./dial_log.txt
while true
do
    echo "====> Start new dial $COUNTER" > $log_file
    sudo ./dial.sh
    COUNTER=$[$COUNTER +1]
    sleep 5
done