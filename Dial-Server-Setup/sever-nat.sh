#!/bin/bash

#https://www.linuxnetworkguru.com/sysctlipv4ip_forward.html

#Check current IP forwarding status
sysctl net.ipv4.ip_forward

# enable ipv4 forward

sysctl -w net.ipv4.ip_forward=1

#Check current IP forwarding status
sysctl net.ipv4.ip_forward




ethernet_src_iface=eth1
ethernet_share_iface=ppp0
sudo iptables --flush
sudo iptables --table nat --flush
sudo iptables --delete-chain
sudo iptables --table nat --delete-chain


# sudo iptables -t nat -A POSTROUTING -o $ethernet_src_iface -j MASQUERADE

# sudo iptables -A FORWARD -i $ethernet_share_iface -o $ethernet_src_iface -m state --state RELATED,ESTABLISHED -j>
# sudo iptables -A FORWARD -i $ethernet_src_iface -o $ethernet_share_iface -j ACCEPT
# #view
# sudo iptables -L -n -v
# sudo iptables -t nat -L -n -v

# or

sudo iptables -t nat -A POSTROUTING -s 10.9.0.0/24 -o $ethernet_src_iface -j MASQUERADE
sudo iptables -t nat -L -n -v
