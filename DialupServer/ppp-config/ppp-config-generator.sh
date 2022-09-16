#!/bin/bash
##########################################
###################PPP config generatir###########################################

##################################################
echo "generate /etc/ppp/options"

sudo bash -c 'cat > /etc/ppp/options' << EOF
noipdefault
ms-dns 8.8.8.8
asyncmap 0
noauth

local
lock
hide-password
modem
-pap
-chap
debug
proxyarp
#lcp-echo-interval 30
#lcp-echo-failure 60
noipx
nocrtscts
#vocal sams optimazation
-detach
lcp-echo-failure 10
lcp-echo-interval 20
lcp-echo-adaptive

netmask 255.255.0.0
EOF

##################################################

echo "generate /etc/ppp/options.ttyACM0 to control ttyACM0"
sudo bash -c 'cat > /etc/ppp/options.ttyACM0' << EOF
# 10.9.0.1 is the gategay(this pc). 
# 10.9.0.2 is the  remote PC call to this pC (phone)
10.9.0.2:10.9.0.1
EOF

#/dev/tntb0 -> /dev/tnt1 : this must be the original name : tnt1 . the tntb0 can not be used here otherwise this configure is not effected
#echo "generate /etc/ppp/options.tnt1"
#sudo bash -c 'cat > /etc/ppp/options.tnt1' << EOF
#10.9.0.4:10.9.0.3
#EOF

for i in {0..7}
do
    idx=$((2*i +1))
    fName="/etc/ppp/options.tnt$idx"
    localIP="10.9.0.$((2*i + 3))"
    remoteIP="10.9.0.$((2*i +4))"
    ipPPP="$remoteIP:$localIP"
    echo "generate $fName with config $ipPPP to control tnt$idx"
#Note : don't tab in the EOF line because    
#When you do << EOF the exactly whole line has to be EOF with no spaces, nor tabs, not before nor after the EOF string.     
sudo bash -c "cat > $fName"<< EOF
# the file name must be the original name : $fName . The tntb$i can not be used here otherwise this configure is not effected
# this is setup for ppp interface at /dev/tntb$i --alias--> /dev/tnt$idx
# serverIP(thisPC) $localIP
# remoteIP(phone) $remoteIP
$ipPPP
EOF

done