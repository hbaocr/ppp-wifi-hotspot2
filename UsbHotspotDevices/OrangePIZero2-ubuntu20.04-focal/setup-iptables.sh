#!/bin/bash

#this is the accessible internet  iface
out_iface=eth0

#this is the iface to connect to devices(phone)
input_iface=usb0

config_iptable(){

    iptables --flush
    iptables --table nat --flush
    iptables --delete-chain
    iptables --table nat --delete-chain
    # nat   :   input_iface  --> out_iface ---> Ethernet
    iptables --table nat --append POSTROUTING --out-interface $out_iface -j MASQUERADE
    iptables --append FORWARD --in-interface $input_iface -j ACCEPT
 
    #Thanks to lorenzo
    #Uncomment the line below if facing problems while sharing PPPoE, see lorenzo's comment for more details
    #iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
 
    sysctl -w net.ipv4.ip_forward=1
    sudo iptables -t nat -L -n -v
}

config_iptable
