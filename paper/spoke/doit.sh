#!/bin/sh
#./hacker
#./hacker2 -m vxlan0 -i eth2 -a 192.100.88.10 -v 21
yum -y install tcpdump
#sh -x ./minion_create -m vxlan0 -i eth2 -a 192.100.88.10 -v 21 -r spoke
sh -x ./minion_create -m vxlan2 -i eth3 -a 192.100.88.10 -v 41 -r spoke -n ab -s Mars 

# Close down port until service ready
#sh -x ./boot_service -m vxlan0 -r spoke -i eth1
#sh -x ./boot_service -m vxlan2 -r spoke -i eth1
sh -x ./boot_service -m boot -r spoke  -b ovs-br1 -I 192.7.7.12 -D 192.7.7.12 -C 192.7.7.4 -B 192.7.7.10



