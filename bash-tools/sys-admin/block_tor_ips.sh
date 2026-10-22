##### ADD TOR IPS TO IP DROP LIST

#!/bin/bash

# create a new set for individual IP addresses
sudo ipset -N tor iphash
# get a list of Tor exit nodes that can access $YOUR_IP, skip the comments and read line by line
sudo wget -q https://check.torproject.org/cgi-bin/TorBulkExitList.py -O -|sed '/^#/d' |while read IP
do
  # add each IP address to the new set, silencing the warnings for IPs that have already been added
  sudo ipset -q -A tor $IP
done
# filter our new set in iptables
sudo iptables -A INPUT -m set --match-set tor src -j DROP
