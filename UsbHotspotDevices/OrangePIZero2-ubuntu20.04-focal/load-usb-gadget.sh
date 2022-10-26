#!/bin/bash

# TO fx g_ether can not load by modprobe because missing in list ( because the legacy driver) 
#depmod creates a list of module dependencies by reading each 
#module under /lib/modules/version and determining what symbols it
#exports and what symbols it needs
sudo depmod
echo "Load g_ther gadget driver"
sudo modprobe g_ether dev_addr=00:22:82:ff:ff:11  host_addr=00:50:b6:14:e1:3e
echo "usb0 interface up"
ifconfig usb0 172.0.0.1 netmask 255.255.255.0 up

echo "restart dhcp dnsmasq"
sudo systemctl restart dnsmasq.service
