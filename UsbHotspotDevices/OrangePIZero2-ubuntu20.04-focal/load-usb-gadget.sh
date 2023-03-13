#!/bin/bash

# TO fx g_ether can not load by modprobe because missing in list ( because the legacy driver) 
#depmod creates a list of module dependencies by reading each 
#module under /lib/modules/version and determining what symbols it
#exports and what symbols it needs
sudo depmod

sudo modprobe libcomposite

echo "Load g_ther gadget driver"
sudo modprobe g_ether dev_addr=00:22:82:ff:ff:11  host_addr=00:50:b6:14:e1:3e

# wait for the udev system to settle down and make sure that all events have been processed before continuing with the script.
sudo udevadm settle -t 5 || :

echo "usb0 interface up"
ifconfig usb0 172.0.0.1 netmask 255.255.255.0 up

#create dnsmasq conf for USB0
sudo bash -c 'cat > /etc/dnsmasq.d/usb0' << EOF
interface=usb0
# remove bind-interfaces : https://www.raspberrypi.org/forums/viewtopic.php?t=215235
# bind-interfaces
bind-dynamic
domain-needed
bogus-priv

dhcp-range=172.0.0.10,172.0.0.240,255.255.255.0,6h

#dhcp-option=3,<gateway address>
dhcp-option=3,172.0.0.1

#dhcp-option=6,<DNS server>
dhcp-option=6,172.0.0.1

log-queries
log-dhcp
listen-address=127.0.0.1

# use Google's DNS servers to route dns requests to if we don't handle them  
server=8.8.8.8
server=8.8.4.4

# allows the use of "myportal" instead of "localhost" or "172.0.0.1". Could also be configured in /etc/hosts
#Redirect (resolve all DNS  query to 172.0.0.1) all requests to 172.0.0.1
#address="/myportal/172.0.0.1" 

# enable this line will force all dns requests will return ip 172.0.0.1 instead of result from 8.8.8.8 server above
# this option will be helpfull incase of captive portal to forbid all dns trafic before login
# Any  traffic out to will be routed to 172.0.0.1 because all dns request ip will return 172.0.0.1

#address=/#/172.0.0.1

#http://www.intellamech.com/RaspberryPi-projects/dnsmasq_whitelist.html
# NEW ITEMS
# Don't resolve any DNS, Blacklist all
no-resolv

# Whitelist domains to DNS lookup
#lookup google.com at dns-server 8.8.8.8
#server=/google.com/8.8.8.8

#lookup d3.drkumo.com at dns-server 8.8.8.8
server=/d3.drkumo.com/8.8.8.8
server=/d3-myhealth.drkumo.com/8.8.8.8
server=/d3-queues.idlogiq.com/8.8.8.8
server=/time.android.com/8.8.8.8
server=/ntp.org/8.8.8.8

# Direct all other domains to
address=/pppdial.net/172.0.0.1
address=/#/127.0.0.1

EOF


echo "restart dhcp dnsmasq"
sudo systemctl restart dnsmasq.service
