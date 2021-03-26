#!/bin/sh
#./hacker
#./hacker2 -m vxlan0 -i eth2 -a 192.100.88.10 -v 21
yum -y install tcpdump
#sh -x ./minion_create -m vxlan0 -i eth2 -a 192.100.88.10 -v 21 -r spoke
sh -x ./minion_create -m vxlan0  -i eth2 -a 192.100.42.20 -v 21 -r hub -n ab -s Earth 
sh -x ./minion_create -m vxlan1  -i eth2 -a 192.100.44.21 -v 31 -r hub -n ab -s Venus 
sh -x ./minion_create -m vxlan2  -i eth2 -a 192.100.46.22 -v 41 -r hub -n ab -s Mars 

#sh -x ./boot_service -m vxlan0 -r spoke -i eth1
sh -x ./etherate_service -m etherate -r hub -b ovs-br1 
#sh -x ./boot_service_hub -m boot -r hub -b ovs-br1 -I 192.7.7.4 -D 192.7.7.4
#sh -x ./boot_service_hub -m boot1 -r hub -b ovs-br2 -I 192.10.7.4 -D 192.10.7.4
sh -x ./boot_service -m boot -r hub -b ovs-br1 -I 192.7.7.4 -D 192.7.7.4 -R 192.7.7.4 -C 192.7.7.4 -B 192.7.7.12



