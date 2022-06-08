#!/bin/sh
#http://man.he.net/man8/pppd
# defaultroute
#               Add a default route to the system routing tables, using the peer
#               as the gateway, when IPCP negotiation is successfully completed.
#               This entry is removed when the PPP connection is  broken.   This
#               option is privileged if the nodefaultroute option has been spec-
#               ified.

# replacedefaultroute
#               This option is a flag to the defaultroute  option.  If  default-
#               route  is set and this flag is also set, pppd replaces an exist-
#               ing default route with the new default route.
# usepeerdns
#           Ask  the  peer  for up to 2 DNS server addresses.  The addresses
#           supplied by the peer (if any) are passed to  the  /etc/ppp/ip-up
#           script in the environment variables DNS1 and DNS2, and the envi-
#           ronment variable USEPEERDNS will be set to 1.  In addition, pppd
#           will  create  an /etc/ppp/resolv.conf file containing one or two
#           nameserver lines with the address(es) supplied by the peer.

CHAT_SCRIPT=$(pwd)/chatscript
DEV=/dev/ttyACM0
BAUD=115200
NUMBER=2001
# pppd 2.4.9 support replacedefaultroute
#pppd usepeerdns noauth local defaultroute replacedefaultroute debug nodetach $DEV $BAUD  connect "/data/local/tmp/chat -v -T$NUMBER -f $CHAT_SCRIPT"

# pppd 2.4.7 didn't support replacedefaultroute
pppd usepeerdns noauth local defaultroute  debug nodetach $DEV $BAUD  connect "/data/local/tmp/chat -v -T$NUMBER -f $CHAT_SCRIPT"
