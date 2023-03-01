#!/bin/bash
##########################################
###################Mgetty config###########################################
##sudo mv /etc/mgetty/mgetty.config /etc/mgetty/mgetty.config.old

sudo bash -c 'cat > /etc/mgetty/issue.drkumo' << EOF
Welcome to DrKumo Dial Up Network
EOF

sudo bash -c 'cat > /etc/mgetty/mgetty.config' << EOF

debug 6
port ttyACM0
 port-owner root
 port-group dialout
 port-mode 0660
 data-only yes
 ignore-carrier no
 toggle-dtr yes
 toggle-dtr-waittime 500
 rings 1
 speed 38400
 modem-check-time 160
 #this line is only for HW modem. For vocal sams server this will let the mgetty on and off
 #--> don't use that for sams vocal
 init-chat "" AT&F OK ATZ OK "ATQ0 V1 E0 S0=0 S2=128 &C1 &D2 +FCLASS=0" OK "AT+MS=V34" OK
 login-prompt \V\n\r\R \m\n\r\P \S (\I)\n\r(\Y)\n\r@ login:\040
 login-time 120
 issue-file /etc/mgetty/issue.drkumo

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
