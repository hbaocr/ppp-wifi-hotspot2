sudo apt-get update
sudo apt-get install build-essential linux-generic libelf-dev  zip unzip ppp net-tools -y
sudo apt install linux-headers-$(uname -r)

sudo dpkg -i SAMS_7.44-1.deb
sudo cp authorization.dat /etc/sams/

cd SAMS_PPP_220203/tty0tty
make
sudo cp tty0tty.ko /etc/sams


sudo systemctl enable sams
#sudo cp /usr/lib/systemd/system/sams.service /lib/systemd/system/
sudo systemctl restart sams




======================
The ATA command is to pick up an incoming call. If you just want to test connectivity to the modem, try "AT" and then you should see an "OK" response.

The RING indications are the result of incoming calls to the SAMS software. Are these incoming calls intentional? You can check in Asterisk why these calls are coming into SAMS, or you can block the incoming calls from the SAMS software itself. This can be done with the modem_incoming_block_range_start and modem_incoming_block_range_end parameters. These define a range of modem channels over which incoming calls will be blocked. Setting them as follows will block all incoming calls:
modem_incoming_block_range_start&3e0=0
modem_incoming_block_range_end&3e0=31
For the /dev/tntb*, this is only applicable if the tty0tty interface is installed. If this is required, we can supply the appropriate source for the customized kernel module that will need to be compiled on the target system and then installed into the kernel. The tty0tty virtual device driver is only required if your application needs the flow control signals from the modem, otherwise the built in pseudo-ttys can be used. If you only need pseudo-ttys (ptys), then you can change the following parameters in the ata2.cfg:
tty_device_name&3f0=/dev/vocal_pts
tty_use_virtual_device&3f0=1
0_tty_uses_sockets&3f0=0

