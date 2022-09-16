#!/bin/bash
##########################################

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
# Restart, but not more than once every 60s (for testing purposes)
StartLimitInterval=60

[Install]
WantedBy=multi-user.target
EOF