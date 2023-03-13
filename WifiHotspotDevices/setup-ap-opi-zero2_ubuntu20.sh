#!/bin/bash

# For ubuntu > 20+ ( kernel >4.9) there are the conflicts betwwen:
#   - Hostapd and Networkmanager built-in hotspot --> if running hostapd -> unstable
#   - The bug of wpasupplicant 2:2.10  using by Networkmanager to control its built-in hotspot --> need to downgrade to 2.9. Link https://bugs.launchpad.net/ubuntu/+source/wpa/+bug/1972790
#   +++ solution -> keep using hostapd  but we need to disable Networkmanager service to avoid the conflict


setup_path="$(pwd)"

##########################################
echo "1. Install required services"
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y hostapd dnsmasq ppp minicom iptables python3 psmisc wget

kernel_version=$(uname -r | awk -F. '{print $1"."$2}')

if [[ "$(echo "$kernel_version > 4.9" | bc)" -eq 1 ]]; then
  echo "Kernel version is greater than to 4.9"
  # downgrade wpasupplicant because of the bug of wpasupplicant
  sudo apt-get install -y wpasupplicant=2:2.9-1ubuntu4.2
                                    
  #sudo apt-get install -y aircrack-ng
else
  echo "Kernel version is less than or equal 4.9"
  exit -1
fi


###install nvm and nodejs
#wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
#source ~/.bashrc
#nvm install 14
#install nodejs
echo '---> Install nodejs 14. Require >= armv7'
curl -sL https://deb.nodesource.com/setup_14.x | bash -
apt-get install -y nodejs



#################use legacy iptables#########################
echo '---> Please select the legacy option of iptables: (1) iptables-legacy'
sudo update-alternatives --config iptables


##########################################

echo "------->2. Stop auto service"
# don't  let it done  auto
# stop  current running instance
sudo systemctl stop dnsmasq.service
# disable restart service
sudo systemctl disable dnsmasq.service 
sudo systemctl stop hostapd
sudo systemctl unmask hostapd
sudo systemctl disable hostapd

sudo killall dnsmasq
sudo killall hostapd
#############################################
echo "------->3. Setup autohotspot service run once  at pwr on"
#create startup executables
sudo bash -c 'cat > /usr/bin/autohotspot.sh' << EOF
#!/bin/bash
cd "$setup_path/bin"
sudo ./wifi_ap_service_startup_opi.sh
EOF
sudo chmod +x /usr/bin/autohotspot.sh

#############################################
echo "------->4. Enable AP Service"
sudo chmod +x "$setup_path/bin/wifi_ap_service_startup_opi.sh"
sudo chmod +x "$setup_path/bin/start_fork_ap_opi.sh"
sudo cp -f ./config_service/autohotspot.service /etc/systemd/system/autohotspot.service
sudo systemctl enable autohotspot.service
sudo systemctl start autohotspot.service

#############################################
echo "------->5. Modify ip-up and ip-down in /etc/ppp to set ethernet defaultroute to ppp when this interface up(dial ok)"
sudo cp -f "$setup_path/bin/ppp/ip-up" /etc/ppp/ip-up
sudo cp -f "$setup_path/bin/ppp/ip-down" /etc/ppp/ip-down
sudo chmod +x /etc/ppp/ip-up
sudo chmod +x /etc/ppp/ip-down

#############################################
echo "------->6. Setup WebAPI nodejs"

chmod +x "$setup_path/WEBAPI/bin/get_gateway_ip.sh"
chmod +x "$setup_path/WEBAPI/bin/get_ppp_ip.sh"
chmod +x "$setup_path/WEBAPI/bin/ppp_dial.sh"
chmod +x "$setup_path/WEBAPI/bin/stop_pppd.sh"

cd "$setup_path/WEBAPI"
npm install

#create startup executables
sudo bash -c 'cat > /etc/systemd/system/webapi.service' << EOF
[Unit]
Description=API PPP Dial Service
Requires=network.target
After=network.target

[Service]
WorkingDirectory=$setup_path/WEBAPI
ExecStart=$(which node) index.js
Restart=always
# Restart service after 10 seconds if node service crashes
RestartSec=10
# Output to syslog
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=nodejs-pppd-dial
[Install]
WantedBy=multi-user.target
EOF

#stop systemd-resolved on port 53 to let dnsmasq be able to work
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
sudo systemctl mask systemd-resolved

# start the service
sudo systemctl enable webapi.service
sudo systemctl start webapi.service


# disbale dnsmasq service also
sudo systemctl stop dnsmasq.service
sudo systemctl disable dnsmasq.service
sudo systemctl mask dnsmasq.service


### Disable NetworkManager service to avoid the conflict with hostapd
sudo systemctl stop NetworkManager.service
sudo systemctl disable NetworkManager.service
sudo systemctl mask NetworkManager.service

#when disable Networkmamanger built-in DHCP client and DNS client also stop
# need to setup ETH0 your self

sudo bash -c 'cat > /etc/resolv.conf' << EOF
nameserver 8.8.8.8
nameserver 8.8.1.1
EOF

#setup for eth0 port
sudo bash -c 'cat > /etc/network/interfaces' << EOF
source /etc/network/interfaces.d/*
# Network is managed by Network manager
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
  address 10.66.77.9
  netmask 255.255.255.0
  gateway 10.66.77.1
EOF

sudo systemctl restart networking.service



#############################################
echo "Reboot service"
sudo reboot

