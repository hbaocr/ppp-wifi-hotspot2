## Note
* Image: [Orangepizero2_2.2.0_ubuntu_focal_server_linux4.9.170.7z](https://drive.google.com/file/d/1LXvrSuMj9fP5Ldnjg1AoVe3AUbsbGWVY/view?usp=sharing) 

Page 123 : g_ether
https://drive.google.com/drive/u/0/search?q=h616

* To load the g_ether gadget ( temporary load) : it will be no longer when rebooting, this is usually useful for testing
```
sudo depmod
modprobe g_ether dev_addr=00:22:82:ff:ff:11  host_addr=00:50:b6:14:e1:3e
ifconfig usb0 172.0.0.1 netmask 255.255.255.0 up
sudo systemctl restart dnsmasq.service
```
* To load when boot —> for permenant load `(This doesn't work on Ubuntu20.04. Don't know exactly reason).` 

```sh
# Maybe because of missing depmod--> cannot find the g_ether.ko when boot.
# In ubuntu20.04, the `g_ether.ko` is moved to legacy path : `/lib/modules/4.9.170-sun50iw9/kernel/drivers/usb/gadget/legacy/g_ether.ko` , it has not existed in default driver path any more
# --> to load the legacy g_ether--> need the creates a list of all module dependencies( include the legacy one) by  `depmod` cmd
```

https://manpages.ubuntu.com/manpages/bionic/en/man5/modules.5.html

      The  /etc/modules  file contains the names of kernel modules that are to be loaded at boot
       time, one per line. Arguments can be given in the same line  as  the  module  name.  Lines
       beginning with a '#' are ignored.

—> Load g_ether when boot ==> add this modules to /etc/modules
```
cat  /etc/modules
sudo echo  g_ether  >> /etc/modules
cat  /etc/modules
```

* Check if gadget is loaded on the host PC ( ubuntu)
```
sudo dmesg
```

* Clear U/L bit of usb0 ethernet gadget

`It is all down to the MAC address that the USB Gadget advertises. You need to advertise a universal address (U/L bit is clear) for the udev rules in Linux (on the Android side) to associate an eth0 device instead of usb0. Once this is done, Android will connect to the device as normal from the settings page, even if it is a composite USB device.`


```sh
echo " change usb0 mac with U/L bit clear in /etc/modprobe.d/g_ether.conf"
sudo bash -c 'cat > /etc/modprobe.d/g_ether.conf' << EOF
options g_ether host_addr=00:50:b6:14:e0:3e dev_addr=00:22:82:ff:ff:11
EOF

```


## Reference

https://stackoverflow.com/questions/72131117/usb-ethernet-on-android-devices

https://forum.armbian.com/topic/1417-g_ether-driver-h3-device-as-ethernet-dongle/page/2/

https://linux-sunxi.org/USB_Gadget/Ethernet

https://forum.armbian.com/topic/1417-g_ether-driver-h3-device-as-ethernet-dongle/page/2/

https://github.com/hbaocr/usb-gadget-rpi/blob/master/set_id.py

