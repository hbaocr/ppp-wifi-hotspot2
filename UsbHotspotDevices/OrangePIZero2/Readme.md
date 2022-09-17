## Note
Page 123 : g_ether
https://drive.google.com/drive/u/0/search?q=h616

* To load the g_ether gadget ( temporary load) : it will be no longer when rebooting, this is usually useful for testing
```
sudo modprobe g_ether
sudo ifconfig usb0 up
sudo ifconfig usb0 192.168.10.10
sudo ifconfig usb0
```
* To load when boot —> for permenant load 

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

