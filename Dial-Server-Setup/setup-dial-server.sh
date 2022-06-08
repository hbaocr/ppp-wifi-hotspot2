##########################################
echo "1. Install required services"
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y ppp mgetty minicom iptables python3

echo "2.Set User for mgetty login"
#user : dream
#pass : dreamcast
#Client chat script have to input this user name and password after connected then run pppd
username=dream
password=dreamcast
#create home for user
mkdir -p  "/home/$username"
# disable welcome screen for this user
sudo touch "/home/$username/.hushlogin"

# create new user name
sudo useradd -G dialout,dip,users -c "$username user" -d "/home/$username" -g users -s /usr/sbin/pppd $username
sudo passwd $username # need to input dreamcast






#setup iptable
#sudo iptables -t nat -A POSTROUTING -s 10.9.0.0/16 -o eth1 -j MASQUERADE
#sudo iptables -t nat -A POSTROUTING -s 10.9.0.0/24 -o eth1 -j MASQUERADE

