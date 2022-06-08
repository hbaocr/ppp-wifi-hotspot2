#!/bin/bash
wifidev="wlan0"
pppdev="ppp0"
ip_gateway="172.0.0.1"
set_static_ip(){
        if ifconfig "$wifidev"  | grep  "inet $ip_gateway"
        then
                echo "already have config AP IP $ip_gateway"
        else
                echo "no config --> Try to set"
                x=1
                while ! ifconfig "$wifidev"  | grep  "inet $ip_gateway" 
                do
                    echo "Try config IP $ip_gateway on AP interface at  $x times"
                    x=$(( $x + 1 ))                     
                     sudo ifconfig "$wifidev" "$ip_gateway" netmask 255.255.255.0 
                     sleep 5
                     if [ $x -gt 10 ]
                     then
                            echo "can not setup static ip $ip_gateway on AP gateway "
                            break
                     fi
                done
        fi
}

#https://nims11.wordpress.com/2013/05/22/using-hostapd-with-dnsmasq-to-create-virtual-wifi-access-point-in-linux/
config_iptable(){

    iptables --flush
    iptables --table nat --flush
    iptables --delete-chain
    iptables --table nat --delete-chain
    # nat   :   wifidev  --> pppdev ---> Ethernet
    iptables --table nat --append POSTROUTING --out-interface $pppdev -j MASQUERADE
    iptables --append FORWARD --in-interface $wifidev -j ACCEPT
 
    #Thanks to lorenzo
    #Uncomment the line below if facing problems while sharing PPPoE, see lorenzo's comment for more details
    #iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
 
    sysctl -w net.ipv4.ip_forward=1
}

start_hostapd(){
        echo "config IPtable"
        config_iptable
        echo "start hostapd"
        sudo killall hostapd
        sudo hostapd ../config_ap/hostapd.conf
}

start_dnsmasq(){
        if [ -z "$(ps -e | grep dnsmasq)" ]
        then
                echo "start new dnsmasag"
                sudo dnsmasq -C ../config_ap/dnsmasq.conf -d
        else
                echo "dnsmasq already started. Kill all and restart"
                sudo killall dnsmasq
                sudo dnsmasq -C ../config_ap/dnsmasq.conf -d
        fi    
}
#default route is pointing to eth0, need to point your default route to ppp0 instead
# if don't set this all ethernet traffic  by default will route to eth0 or wlan0
# make sure you set default route = ppp0 if you want to let wlan0 get internet from ppp0
set_default_route(){
        sudo ip route add default dev $pppdev
}

echo "0. Kill wpa_supplicant to release wlan0"
# kill wpa_supplicant to release wlan0
sudo killall wpa_supplicant
sleep 1

sudo ifconfig "$wifidev" down
sleep 1
sudo ifconfig "$wifidev" up
echo "1.setup static IP address $ip_gateway"
set_static_ip

echo "2.Set default route is: $pppdev."
set_default_route

echo "3.start AP"
#  start subshell to  fork thread http://tldp.org/LDP/abs/html/subshells.html 
#  Running parallel processes in subshells by using &
start_hostapd & # fork this process and run parallel
sleep 60
echo "start dnsmag=====>"
start_dnsmasq # fork this process and run parallel