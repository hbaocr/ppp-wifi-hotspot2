#!/bin/bash
#orangepi debian buster : Orangepizero2_2.2.0_ubuntu_focal_server_linux4.9.170.7z
#https://drive.google.com/file/d/1LXvrSuMj9fP5Ldnjg1AoVe3AUbsbGWVY/view?usp=sharing


# Android App --> Android system network --> VPN tunnel --->Usb AOA --->|Phone USB C port| 
#                                                                               |
#                                                                               |
#                                                                               V
#                                                                       [USB A port OPI(host)]
#                                                                               |
#                                                                               |
#                                                                               V
# OuputIface(wlan0| eth0| ppp0) <---- Iptable <--- Tun0(10.10.10.1) <--- SimpleRT(ServerApp run as service)
#                                                    ^
#                                                    ^  
#                                                  DnsServer(Dnsmasq) bind to Tun0(10.10.10.1)
#                                                  Do whilelist to resolve name request
                                

sudo apt install -y build-essential pkg-config libusb-1.0-0-dev

setup_path="$(pwd)"

##########################################
echo " Pull USB Revert Tether server code"
git clone https://github.com/hbaocr/Android-reverthering-USB.git

echo "Overide DrKumo USB AOA Information"
cp -f ./patch/revert-server/adk.c ./Android-reverthering-USB/simple-rt-cli/src/adk.c

cd Android-reverthering-USB/simple-rt-cli/
make
sudo make install

##########################################
echo " Setup usb reverse tether run as the service when boot"

usbReverseExe="$(which simple-rt)"
# this is tun0 addr, there is dnsmasq bind to this tun0
dnsBindIface="tun0"
dnsServer="10.10.10.1"
outIface="wlan0"
revertTetherCmd="$usbReverseExe -i $outIface -n $dnsServer"
echo "run: $revertTetherCmd as the service"

SERVICE_NAME=usbRervertTether.service
SERVICE_FILE=/etc/systemd/system/$SERVICE_NAME
cat << EOF | sudo tee $SERVICE_FILE > /dev/null
[Unit]
Description=usb-aoa-rervert-tether
Requires=network.target
After=network.target

[Service]
#WorkingDirectory=$cmd_path
ExecStart=$revertTetherCmd
Restart=always
# Restart service after 10 seconds if node service crashes
RestartSec=10
# Output to syslog
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=usb-aoa-rervert-tether
[Install]
WantedBy=multi-user.target
EOF

echo "Created $SERVICE_FILE"
sudo systemctl enable $SERVICE_NAME
sudo systemctl restart $SERVICE_NAME

##########################################
echo " Setup dns server bind to reverse tether tunnel $dnsBindIface"
#/etc/dnsmasq.d/tun0
DNS_CONFIG_FILE=/etc/dnsmasq.d/$dnsBindIface

cat << EOF | sudo tee $DNS_CONFIG_FILE > /dev/null
interface=$dnsBindIface
# remove bind-interfaces : https://www.raspberrypi.org/forums/viewtopic.php?t=215235
# bind-interfaces
bind-dynamic
domain-needed
bogus-priv

#dhcp-range=172.0.0.10,172.0.0.240,255.255.255.0,6h

#dhcp-option=3,<gateway address>
#dhcp-option=3,172.0.0.1

#dhcp-option=6,<DNS server>
#dhcp-option=6,172.0.0.1

log-queries
#log-dhcp
#listen-address=127.0.0.1

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
#server=/d3.drkumo.com/8.8.8.8
#server=/d3-myhealth.drkumo.com/8.8.8.8
#server=/d3-queues.idlogiq.com/8.8.8.8

# allow *.idlogiq.com
server=/.idlogiq.com/8.8.8.8

# allow *.drkumo.com
server=/d3.drkumo.com/8.8.8.8

server=/time.android.com/8.8.8.8
server=/ntp.org/8.8.8.8

# Direct all other domains to
address=/pppdial.net/$dnsServer
address=/#/$dnsServer

EOF


echo "restart dhcp dnsmasq"
sudo systemctl restart dnsmasq.service



