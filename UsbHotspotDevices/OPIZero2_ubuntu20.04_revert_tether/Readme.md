## Note
* Image: [Orangepizero2_2.2.0_ubuntu_focal_server_linux4.9.170.7z](https://drive.google.com/file/d/1LXvrSuMj9fP5Ldnjg1AoVe3AUbsbGWVY/view?usp=sharing) 

* Working flow
```sh
# Android App --> Android system network --> VPN tunnel(10.10.10.2)---> Android VPN apk --->Usb AOA --->|Phone USB C port| 
#                                                                                                             |
#                                                                                                             |
#                                                                                                             V
#                                                                                                    [USB A port OPI(host)]
#                                                                                                             |
#                                                                                                             |
#                                                                                                             V
# OuputIface(wlan0| eth0| ppp0) <---- Iptable script by serverApp <--- Tun0(10.10.10.1) <--- SimpleRT(ServerApp run as service)
#                                                                               ^
#                                                                               ^  
#                                                  DnsServer(Dnsmasq) bind to Tun0(10.10.10.1)
#                                                  Do whilelist to resolve name request

```

* Setup CMD

```sh
sudo ./install-all.sh
```



