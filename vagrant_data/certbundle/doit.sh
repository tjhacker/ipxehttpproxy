#!/bin/sh
#./hacker
#./hacker2 -m vxlan0 -i eth2 -a 192.100.88.10 -v 21
yum -y install tcpdump
#sh -x ./minion_create -m vxlan0 -i eth2 -a 192.100.88.10 -v 21 -r spoke
sh -x ./minion_create -m vxlan0 -i eth3 -a 192.100.88.10 -v 21 -r spoke
# Close down port until service ready
sh -x ./boot_service -m vxlan0 -r spoke -i eth1



