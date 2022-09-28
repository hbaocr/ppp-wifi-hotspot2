
#!/bin/bash
setup_path="$(pwd)"
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

sudo systemctl enable webapi.service
sudo systemctl start webapi.service

#############################################
echo "Reboot service"
sudo reboot