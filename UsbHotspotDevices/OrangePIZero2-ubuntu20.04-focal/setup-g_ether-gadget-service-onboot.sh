#!/bin/bash
EXEPATH=$(pwd)
LOAD_USB_GADGET=$EXEPATH/load-usb-gadget.sh
SERVICE_NAME=usb-gadget.service
SERVICE_FILE=/etc/systemd/system/$SERVICE_NAME

# make sure $USBFILE runs on every boot using $UNITFILE
if [[ ! -e $SERVICE_FILE ]] ; then
    cat << EOF | sudo tee $SERVICE_FILE > /dev/null
[Unit]
Description=USB gadget initialization
After=network-online.target
Wants=network-online.target
#After=systemd-modules-load.service
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=$LOAD_USB_GADGET
[Install]
WantedBy=sysinit.target
EOF
    echo "Created $SERVICE_FILE"
    sudo systemctl enable $SERVICE_NAME
    sudo systemctl restart $SERVICE_NAME
fi




