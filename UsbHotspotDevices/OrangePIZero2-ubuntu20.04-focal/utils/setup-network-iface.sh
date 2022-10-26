#!/bin/bash


################################################################
# setup network interface of usb0
#https://unix.stackexchange.com/questions/128439/good-detailed-explanation-of-etc-network-interfaces-syntax
echo "setup usb0 network interface at /etc/network/interfaces"
sudo bash -c 'cat > /etc/network/interfaces' << EOF
source /etc/network/interfaces.d/*
# Network is managed by Network manager
auto lo
iface lo inet loopback

# usb0 gadget
# setup  allow-hotplug usb0 before auto usb0 --> make sure this iface allow auto on at boot and hotplug
allow-hotplug usb0
auto usb0
iface usb0 inet static
    address 172.0.0.1
    netmask 255.255.255.0
    post-up /etc/network/if-up.d/iptable-setup.sh

#allow-hotplug ppp0
auto ppp0
iface ppp0 inet manual
    post-up /etc/network/if-up.d/iptable-setup.sh

EOF

#'EOF' --> ignore to process $ --> keep $ as it is to print out $para (include $)
echo "post-script run after this usb0 plug in at /etc/network/interfaces"
sudo bash -c 'cat > /etc/network/if-up.d/iptable-setup.sh' << 'EOF'
#!/bin/bash

#this is the accessible internet  iface
# route usb0 ---> ppp0
out_iface=ppp0

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
EOF
sudo chmod +x /etc/network/if-up.d/iptable-setup.sh

