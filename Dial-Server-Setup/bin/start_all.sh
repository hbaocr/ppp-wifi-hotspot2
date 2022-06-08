#!/bin/bash

echo "Route IP table"

sudo iptables --flush
sudo iptables --table nat --flush
sudo iptables --delete-chain
sudo iptables --table nat --delete-chain

sudo iptables -t nat -A POSTROUTING -s 10.9.0.0/16 -o eth1 -j MASQUERADE

sudo ./start_mgetty.sh /dev/tntb0 &
sleep 0.5

sudo ./start_mgetty.sh /dev/tntb1 &
sleep 0.5

sudo ./start_mgetty.sh /dev/tntb2 &
sleep 0.5

sudo ./start_mgetty.sh /dev/tntb3 &
sleep 0.5

sudo ./start_mgetty.sh /dev/tntb4 &
sleep 0.5

sudo ./start_mgetty.sh /dev/tntb5 &
sleep 0.5

sudo ./start_mgetty.sh /dev/tntb6 &
sleep 0.5

sudo ./start_mgetty.sh /dev/tntb7 &
sleep 0.5

