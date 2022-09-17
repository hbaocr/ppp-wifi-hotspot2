#!/bin/bash
IFACE=ppp0
ifconfig $IFACE |grep "inet " | awk '{print $2}'