#!/bin/bash

gatewayIface=usb0

ip_gateway="172.0.0.1"
ifconfig "$gatewayIface" up
sleep 3
set_static_ip(){
        if ifconfig "$gatewayIface"  | grep  "inet $ip_gateway"
        then
                echo "already have config AP IP $ip_gateway"
        else
                echo "no config --> Try to set"
                x=1
                while ! ifconfig "$gatewayIface"  | grep  "inet $ip_gateway" 
                do
                    echo "Try config IP $ip_gateway on AP interface at  $x times"
                    x=$(( $x + 1 ))                     
                     sudo ifconfig "$gatewayIface" "$ip_gateway" netmask 255.255.255.0 
                     sleep 5
                     if [ $x -gt 10 ]
                     then
                            echo "can not setup static ip $ip_gateway on AP gateway "
                            break
                     fi
                done
        fi
}

set_static_ip



systemctl restart dnsmasq.service 
