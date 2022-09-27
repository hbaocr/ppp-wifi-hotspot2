#!/bin/bash

#reload the g_ether driver
#sudo modprobe -r g_ether && sudo modprobe g_ether

#Make sure otg_role is set.
#If otg_role is not set to usb_device mode, you can use the following command to open
sudo cat /sys/devices/platform/soc/usbc0/usb_device
#------->device_chose finished!

#The Linux system configures USB0 as usb_device mode by default. 
#You can check the status of otg_role through the following command
cat /sys/devices/platform/soc/usbc0/otg_role 
#------>usb_device


################################################################
echo "Setup auto load g_ether module when booting"
#Load g_ether when boot ==> add this modules to /etc/modules
cat  /etc/modules
sudo echo  g_ether  >> /etc/modules
cat  /etc/modules

################################################################
# this setup to let usb0 g_ether will use the mac which U/L bit is cleared to let android phone be able to regcogize this 
# plug into usb0 devices as ethernet card
echo " change usb0 mac with U/L bit clear in /etc/modprobe.d/g_ether.conf"
sudo bash -c 'cat > /etc/modprobe.d/g_ether.conf' << EOF
options g_ether host_addr=00:50:b6:14:e0:3e dev_addr=00:22:82:ff:ff:11 use_eem=0
EOF



################################################################
# setup network interface of usb0
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

# this need to be retested
# ppp0 gadget
#auto ppp0
allow-hotplug ppp0
#iface ppp0 inet static
#post-up /etc/network/if-up.d/iptable-setup.sh

EOF

#'EOF' --> ignore to process $ --> keep $ as it is to print out $para (include $)
# echo "post-script run after this usb0 plug in at /etc/network/interfaces"
# sudo bash -c 'cat > /etc/network/if-up.d/iptable-setup.sh' << 'EOF'
# #!/bin/bash

# #this is the accessible internet  iface
# out_iface=eth0

# #this is the iface to connect to devices(phone)
# input_iface=usb0

# config_iptable(){

#     iptables --flush
#     iptables --table nat --flush
#     iptables --delete-chain
#     iptables --table nat --delete-chain
#     # nat   :   input_iface  --> out_iface ---> Ethernet
#     iptables --table nat --append POSTROUTING --out-interface $out_iface -j MASQUERADE
#     iptables --append FORWARD --in-interface $input_iface -j ACCEPT
 
#     #Thanks to lorenzo
#     #Uncomment the line below if facing problems while sharing PPPoE, see lorenzo's comment for more details
#     #iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
 
#     sysctl -w net.ipv4.ip_forward=1
#     sudo iptables -t nat -L -n -v
# }
# config_iptable
# EOF
# sudo chmod +x /etc/network/if-up.d/iptable-setup.sh

