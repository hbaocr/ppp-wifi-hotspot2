#!/bin/bash
#######################################################
#https://dogemicrosystems.ca/wiki/Dial-up_pool
#sudo iptables --table nat --append POSTROUTING --out-interface enp0s3 -j MASQUERADE
#Create a systemd service for mgetty, by editing /lib/systemd/system/mgetty@.service (note the @) with your text editor of choice as root or sudo.

# create startup executables
#  %i will be replace when calling the systemcmd for example : i = ttyUSB0
#  sudo systemctl enable mgetty@ttyUSB0.service


mgetty_path="$(which mgetty)"
echo $mgetty_path
sudo bash -c 'cat > /lib/systemd/system/mgetty@.service' << EOF
[Unit]
Description=External Modem %I
Documentation=man:mgetty(8)
Requires=systemd-udev-settle.service
After=systemd-udev-settle.service

[Service]
Type=simple
#ExecStart=/usr/sbin/mgetty -x 6 /dev/%i
ExecStart=$mgetty_path -x 6 /dev/%i

Restart=always
PIDFile=/var/log/mgetty.pid.%i
#https://www.freedesktop.org/software/systemd/man/systemd.service.html
#Configures the time to sleep before restarting a service
RestartSec=90


[Install]
WantedBy=multi-user.target
EOF

sudo systemctl disable mgetty@tntb0.service
sudo systemctl disable mgetty@tntb1.service
sudo systemctl disable mgetty@tntb2.service
sudo systemctl disable mgetty@tntb3.service
sudo systemctl disable mgetty@tntb4.service
sudo systemctl disable mgetty@tntb5.service
sudo systemctl disable mgetty@tntb6.service
sudo systemctl disable mgetty@tntb7.service

sudo systemctl enable mgetty@tntb0.service
sudo systemctl enable mgetty@tntb1.service
sudo systemctl enable mgetty@tntb2.service
sudo systemctl enable mgetty@tntb3.service
sudo systemctl enable mgetty@tntb4.service
sudo systemctl enable mgetty@tntb5.service
sudo systemctl enable mgetty@tntb6.service
sudo systemctl enable mgetty@tntb7.service

sudo systemctl start mgetty@tntb0.service
sudo systemctl start mgetty@tntb1.service
sudo systemctl start mgetty@tntb2.service
sudo systemctl start mgetty@tntb3.service
sudo systemctl start mgetty@tntb4.service
sudo systemctl start mgetty@tntb5.service
sudo systemctl start mgetty@tntb6.service
sudo systemctl start mgetty@tntb7.service


