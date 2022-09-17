#!/bin/bash
IFACE=wlan0
ifconfig $IFACE |grep "inet " | awk '{print $2}'