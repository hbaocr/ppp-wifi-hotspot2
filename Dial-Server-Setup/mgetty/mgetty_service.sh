#!/bin/bash
#https://dogemicrosystems.ca/wiki/Dial-up_pool
#sudo iptables --table nat --append POSTROUTING --out-interface enp0s3 -j MASQUERADE
#Create a systemd service for mgetty, by editing /lib/systemd/system/mgetty@.service (note the @) with your text editor of choice as root or sudo.

# create startup executables
#  %i will be replace when calling the systemcmd for example : i = ttyUSB0
#  sudo systemctl enable mgetty@ttyUSB0.service
sudo bash -c 'cat > /lib/systemd/system/mgetty@.service' << EOF
[Unit]
Description=External Modem %I
Documentation=man:mgetty(8)
Requires=systemd-udev-settle.service
After=systemd-udev-settle.service

[Service]
Type=simple
ExecStart=/usr/sbin/mgetty -x 6 /dev/%i
Restart=always
PIDFile=/var/log/mgetty.pid.%i

[Install]
WantedBy=multi-user.target
EOF



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


###################Mgetty config###########################################
sudo bash -c 'cat > /etc/mgetty/mgetty.config' << EOF
issue-file /etc/issue.mgetty
debug 6
port tntb0
 port-owner root
 port-group dialout
 port-mode 0660
 data-only yes
 ignore-carrier no
 toggle-dtr yes
 toggle-dtr-waittime 500
 rings 2
 speed 115200
 modem-check-time 160
 #this line is only for HW modem. For vocal sams server this will let the mgetty on and off 
 #--> don't use that for sams vocal
 ##init-chat "" "ATQ0 V1 E0 S0=0 S2=128 &C1 &D2 +FCLASS=0" OK
 

 login-prompt \V\n\r\R \m\n\r\P \S (\I)\n\r(\Y)\n\r@ login:\040
 login-time 120 
 issue-file /etc/mgetty/issue.tntb0

port tntb1
 port-owner root
 port-group dialout
 port-mode 0660
 data-only yes
 ignore-carrier no
 toggle-dtr yes
 toggle-dtr-waittime 500
 rings 2
 speed 115200
 modem-check-time 160
 #init-chat "" "ATQ0 V1 E0 S0=0 S2=128 &C1 &D2 +FCLASS=0" OK
 login-prompt \V\n\r\R \m\n\r\P \S (\I)\n\r(\Y)\n\r@ login:\040
 login-time 120 
 issue-file /etc/mgetty/issue.tntb1


port tntb2
 port-owner root
 port-group dialout
 port-mode 0660
 data-only yes
 ignore-carrier no
 toggle-dtr yes
 toggle-dtr-waittime 500
 rings 2
 speed 115200
 modem-check-time 160
 #init-chat "" "ATQ0 V1 E0 S0=0 S2=128 &C1 &D2 +FCLASS=0" OK
 login-prompt \V\n\r\R \m\n\r\P \S (\I)\n\r(\Y)\n\r@ login:\040
 login-time 120 
 issue-file /etc/mgetty/issue.tntb2

port tntb3
 port-owner root
 port-group dialout
 port-mode 0660
 data-only yes
 ignore-carrier no
 toggle-dtr yes
 toggle-dtr-waittime 500
 rings 2
 speed 115200
 modem-check-time 160
 #init-chat "" "ATQ0 V1 E0 S0=0 S2=128 &C1 &D2 +FCLASS=0" OK
 login-prompt \V\n\r\R \m\n\r\P \S (\I)\n\r(\Y)\n\r@ login:\040
 login-time 120 
 issue-file /etc/mgetty/issue.tntb3

port tntb4
 port-owner root
 port-group dialout
 port-mode 0660
 data-only yes
 ignore-carrier no
 toggle-dtr yes
 toggle-dtr-waittime 500
 rings 2
 speed 115200
 modem-check-time 160
 #init-chat "" "ATQ0 V1 E0 S0=0 S2=128 &C1 &D2 +FCLASS=0" OK
 login-prompt \V\n\r\R \m\n\r\P \S (\I)\n\r(\Y)\n\r@ login:\040
 login-time 120 
 issue-file /etc/mgetty/issue.tntb4


port tntb5
 port-owner root
 port-group dialout
 port-mode 0660
 data-only yes
 ignore-carrier no
 toggle-dtr yes
 toggle-dtr-waittime 500
 rings 2
 speed 115200
 modem-check-time 160
 #init-chat "" "ATQ0 V1 E0 S0=0 S2=128 &C1 &D2 +FCLASS=0" OK
 login-prompt \V\n\r\R \m\n\r\P \S (\I)\n\r(\Y)\n\r@ login:\040
 login-time 120 
 issue-file /etc/mgetty/issue.tntb5

port tntb6
 port-owner root
 port-group dialout
 port-mode 0660
 data-only yes
 ignore-carrier no
 toggle-dtr yes
 toggle-dtr-waittime 500
 rings 2
 speed 115200
 modem-check-time 160
 #init-chat "" "ATQ0 V1 E0 S0=0 S2=128 &C1 &D2 +FCLASS=0" OK
 login-prompt \V\n\r\R \m\n\r\P \S (\I)\n\r(\Y)\n\r@ login:\040
 login-time 120 
 issue-file /etc/mgetty/issue.tntb6


port tntb7
 port-owner root
 port-group dialout
 port-mode 0660
 data-only yes
 ignore-carrier no
 toggle-dtr yes
 toggle-dtr-waittime 500
 rings 2
 speed 115200
 modem-check-time 160
 #init-chat "" "ATQ0 V1 E0 S0=0 S2=128 &C1 &D2 +FCLASS=0" OK
 login-prompt \V\n\r\R \m\n\r\P \S (\I)\n\r(\Y)\n\r@ login:\040
 login-time 120 
 issue-file /etc/mgetty/issue.tntb7

EOF