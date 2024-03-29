





## Note
* Install:
```sh
sudo apt-get install -y hostapd dnsmasq ppp minicom iptables
```

## To install:

* For RPI3, RPI4, RPI zero2w
```sh
cd WifiHotspotDevices
chmod +x setup-ap-rpi-zero2w.sh
sudo ./setup-ap-rpi-zero2w.sh
```



* For [orangepi zero2(h616)](http://www.orangepi.org/html/hardWare/computerAndMicrocontrollers/service-and-support/Orange-Pi-Zero-2.html) : 
    * If you want just burn and run without any setup, burn [this image 30-09-2022](https://drive.google.com/file/d/19a28wsbkQL9mrA4Azxs6USlQh_GoAZs3/view?usp=sharing) by Belena Etcher.
        
        * Add to  SSE server sent event in web/index.html to dial from web  

    * If you want just burn and run without any setup, burn [this image 28-09-2022](https://drive.google.com/file/d/1yBDT1i4S36sehqRUnhSbW7uspNMZJCj8/view?usp=sharing) by Belena Etcher. 
        * g_ether (use_eem=0) using ecm mode through usb0 otg. H616 will play as hotspot and assign ip to the plugin phone or pc through dnsmasq
        * dnsmasq.conf : only allow to resolve IP of some domain specific in this file, otherwise to route 172.0.0.1
        * ppp0 script control by webapi. please access the domain `pppdial.net:5099/dial` to dial 
        * iptable nat `usb0(input iface)-------->pppp0(out put iface)`

    * If you want to setup yourself from beginnig, use the following image and follow the instruction to install.

        * Image name(current working) :[Orangepizero2_2.2.0_ubuntu_bionic_server_linux4.9.170.7z](https://drive.google.com/file/d/1FWcSAgclSTHlzJOidboPboCIzMTiKs9A/view?usp=sharing)
        * Image name :  [Orangepizero2_2.2.0_debian_buster_desktop_linux4.9.170.7z](https://drive.google.com/file/d/1aTNyzHfoh_EehlEc7t1IUmlwO9-1h4mH/view?usp=sharing)
        * Image name : [Orangpizero2_ubuntu_bionic_server_wifi_pp_dial_linux4.9.170_20230207](https://drive.google.com/file/d/1Wex6QzWUKevh78XkXinmAYehOM_CNo2h/view?usp=share_link)
        * Flash by : balena Etcher
    
    * if you want option `usb0-->ppp0` :
        ```sh
        cd ppp-wifi-hotspot2/UsbHotspotDevices/OrangePIZero2
        chmod +x *.sh
        sudo ./install-all.sh
        ```
    * if you want option `wlan0(ap)  ---> ppp0`

        ```sh
        cd WifiHotspotDevices
        chmod +x setup-ap-orangepi-zero2.sh
        sudo ./setup-ap-orangepi-zero2.sh
        ```



## Problem 
---
### `dnsmasq: failed to create listening socket for port 53: Address already in use`
* (Link)(https://askubuntu.com/questions/191226/dnsmasq-failed-to-create-listening-socket-for-port-53-address-already-in-use)
* check `sudo ss -lp "sport = :domain"`
* `stop systemd-resolved on port 53`

```sh
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
sudo systemctl mask systemd-resolved
```



---
### `iptables v1.8.2 (nf_tables): Chain 'MASQUERADE' does not exist`

https://github.com/pivpn/pivpn/issues/751

```
update-alternatives --config iptables
```
selected the legacy version. Re-ran the debug command and the script was able to auto-fix.



### `[1] Hostapd:  'wlan0: STA 24:43:e2:50:31:ff IEEE 802.11: disassociated'`

That may cause wlan0  was already in STA mode and can not start AP mode.In STA the wlan0 is controlled by **wpa_supplicant** ==> To solve just kill wpa_supplicant and try to start hostapad on wlan0 :
```sh
# kill wpa_supplicant to release wlan0
sudo killall wpa_supplicant
# start AP on wlan0 ( configured by hostapd.conf)
sudo hostapd /etc/hostapd/hostapd.conf

```

This will temporary disable wpa_supplicant, to forbid wpa_supplicant run at next boot up --> disable wpa_supplicant service

```sh
sudo systemctl stop wpa_supplicant
sudo systemctl disable wpa_supplicant
```
---

### `[2]. pppd dont replace defaultroute `

This problem is a known bug of pppd at [link](https://github.com/ppp-project/ppp/issues/115)

That cause the system don't use ppp0 as default routing for ethernet. By default system may use eth0 or wlan0 as default route for ethernet.

* To check route 
```sh
ip route show
```


IF we want to use ppp0 as default internet source of system in case :   
```sh
                  |--------------Raspbery PI------------|
                  |                                     | 
client-phone ---->| Wifi AP ( wlan0) -----nat----> ppp0 |---> Dial UP Ethernet
                  |                                     |
                  |-------------------------------------|
```

we need to set ppp0 as default internet route 
```sh
sudo ip route add default dev ppp0
```
`Note that: this command can only work if  the interface ppp0 is established and availble. When dial OK and setup the pppd OK. Otherwise it will show the error can not find ppp0 interface`

* As a workaraound, create executable shell script at the end of: /etc/ppp/ip-up:
```sh
    route add default dev ppp0
```
 and and at the end of /etc/ppp/ip-down 
```sh
   route del default dev ppp0
```




######
Reference
* https://cdn-reichelt.de/documents/datenblatt/G100/8560C1_MANUAL.pdf

* Run cmd in sudo without password
```sh
#Other requirement is about permission levels. To properly execute the provided methods the application that uses the module must have the proper sudo privileges. One way to do it could be by adding a custom user to the system:

sudo adduser --no-create-home <user-run-sudo-without-password>

#then add its permissions at /etc/sudoers file:

<user-run-sudo-without-password> ALL=NOPASSWD: /sbin/iptables, /sbin/ip6tables, /sbin/ipset

# here : /sbin/iptables, /sbin/ip6tables, /sbin/ipset can run with sudo without password
```

* Automatically re-apply the iptable rule on system reboot
 
```sh
sudo apt-get install iptables-persistent
sudo /etc/init.d/iptables-persistent save
```




