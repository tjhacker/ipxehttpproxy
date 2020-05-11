#!/bin/bash
export VAGRANT_ROLE=$1
export REMOTE_IRISIP=$2
export LOCALIP=$3
echo $VAGRANT_ROLE
echo $REMOTE_IRISIP

echo $VIRTSWITCH_ADAPTER


if [ $# != 3 ] || ([ ${VAGRANT_ROLE} != "hub" ] && [ ${VAGRANT_ROLE} != "spoke" ]) ; then
	echo "Usage: setup_ipsec <hub|spoke> <remote IPsec address for VXlan endpoint><Local secure IP address>"
	exit
fi

# Hostfile

 
        if [ $VAGRANT_ROLE == "hub" ]
	then
# %DNSmasq
	     m4 -DMOON_IPADDR="10.210.210.41" /usr/local/src/ipxe/ipxehttpproxy/strongswan/hosts.m4 > /etc/hosts
#	     cat /usr/local/src/ipxe/ipxehttpproxy/Olympus/hosts >> /etc/hosts
	fi


        if [ $VAGRANT_ROLE == "spoke" ]
	then
	# %jumphost
	     cat /usr/local/src/ipxe/ipxehttpproxy/Juno/hosts >> /etc/hosts
	fi


 # ipsec (strongswan)

# Firewall rules to allow IPsec and VXlan
     firewall-cmd --zone=dmz --permanent --add-rich-rule='rule protocol value="esp" accept'
     firewall-cmd --zone=dmz --permanent --add-rich-rule='rule protocol value="ah" accept'
     firewall-cmd --zone=dmz --permanent --add-port=500/udp
     firewall-cmd --zone=dmz --permanent --add-port=4500/udp
     firewall-cmd --permanent --add-service="ipsec"
     firewall-cmd --permanent --add-port=8472/udp # vxlan port
     firewall-cmd --permanent --add-port=8472/udp --zone=dmz # vxlan port

   firewall-cmd --reload
# Certificate management
#  %DNSmasq

        if [ $VAGRANT_ROLE == "hub" ]
	then
		mkdir -p /home/vagrant/certs
		cd /home/vagrant/certs
		# Create X509 certficates for server and jumphost
		strongswan pki --gen --outform pem > CAKey.key
		strongswan pki --self --in CAKey.key --dn "C=US,ST=Indiana,L=West Lafayette,O=Purdue University,emailAddress=tjhacker@purdue.edu,CN=strongSwan CA" --ca --outform pem > CA.crt
		strongswan pki --gen --outform pem > hostSunKey.key
		strongswan pki --gen --outform pem > hostMoonKey.key
#		strongswan pki --issue --in hostSunKey.key --type priv --cacert CA.crt --cakey CAKey.key --dn "C=US,ST=Indiana,L=West Lafayette,O=Purdue University,emailAddress=tjhacker@purdue.edu,CN=sun.localdomain, OU=CIT" --san sun.localdomain --outform pem  --addrblock "192.7.7.0/24" --ca  > hostSunCert.crt 
		strongswan pki --issue --in hostSunKey.key --type priv --cacert CA.crt --cakey CAKey.key --dn "C=US,ST=Indiana,L=West Lafayette,O=Purdue University,emailAddress=tjhacker@purdue.edu,CN=sun.localdomain, OU=CIT" --san sun.localdomain --outform pem   > hostSunCert.crt 
#		strongswan pki --issue --in hostMoonKey.key --type priv --cacert CA.crt --cakey CAKey.key --dn "C=US,ST=Indiana,L=West Lafayette,O=Purdue University,emailAddress=tjhacker@purdue.edu,CN=moon.localdomain,OU=CIT" --outform pem  --addrblock "192.7.7.0/24" --ca  > hostMoonCert.crt 
		strongswan pki --issue --in hostMoonKey.key --type priv --cacert CA.crt --cakey CAKey.key --dn "C=US,ST=Indiana,L=West Lafayette,O=Purdue University,emailAddress=tjhacker@purdue.edu,CN=moon.localdomain,OU=CIT" --san moon.localdomain --outform pem    > hostMoonCert.crt 
	fi


        if [ $VAGRANT_ROLE == "spoke" ]
	then
		rsync -e "ssh -p 59842 -o 'StrictHostKeyChecking no'" vagrant@moon:/home/vagrant/certs/CA.crt vagrant@moon:/home/vagrant/certs/host*Cert.crt vagrant@moon:/home/vagrant/certs/hostSunKey.key  /home/vagrant/certs
	fi

        if [ $VAGRANT_ROLE == "hub" ]
	then
           # strongswan configuration file for hub

##	    m4 -D__LOCAL_FQDN="moon.localdomain" -D__REMOTE_FQDN="sun.localdomain" -D__LOCAL_CERT="hostMoonCert.crt" -D__REMOTE_CERT="hostSunCert.crt" -D__LOCALIP_TS="192.100.88.0/24" -D__REMOTEIP_TS="192.100.42.0/24" uni.conf.m4 > /etc/strongswan/swanctl/conf.d/Olympus.ab.conf
    m4 -D__LOCAL_FQDN="moon.localdomain" -D__LOCAL_CERT="hostMoonCert.crt" -D__LOCALIP_TS="192.100.88.0/24" -D__REMOTEIP_TS="192.100.42.0/24" /usr/local/src/ipxe/ipxehttpproxy/strongswan/uni.conf.m4 > /etc/strongswan/swanctl/conf.d/Olympus.ab.conf
#	    cp /vagrant_data/hostMoonKey.key /etc/strongswan/swanctl/private
	    cp /home/vagrant/certs/hostMoonKey.key /etc/strongswan/swanctl/private
	fi

# %jumphost
        if [ $VAGRANT_ROLE == "spoke" ]
	then
            # strongswan configuration file for spoke
	    m4 -D__LOCAL_FQDN="sun.localdomain" -D__REMOTE_FQDN="moon.localdomain" -D__LOCAL_CERT="hostSunCert.crt" -D__REMOTE_CERT="hostMoonCert.crt" -D__LOCALIP_TS="192.100.42.0/24" -D__REMOTEIP_TS="192.100.88.0/24" /usr/local/src/ipxe/ipxehttpproxy/strongswan/uni.conf.m4 > /etc/strongswan/swanctl/conf.d/ab.conf
	    cp /home/vagrant/certs/hostSunKey.key /etc/strongswan/swanctl/private
	fi

# %jumphost
        if [ $VAGRANT_ROLE == "spoke" ]
	then
            # strongswan configuration file for spoke
	    cp /usr/local/src/ipxe/ipxehttpproxy/Juno/ab.conf /etc/strongswan/swanctl/conf.d/ab.conf
    	    cp /home/vagrant/certs/hostSunKey.key /etc/strongswan/swanctl/private
	fi

     # Install certficates for strongswan
     cp /home/vagrant/certs/CA.crt /etc/strongswan/swanctl/x509ca
     cp /home/vagrant/certs/host*Cert.crt /etc/strongswan/swanctl/x509




     systemctl enable strongswan
     systemctl start strongswan


# Turn on strongswan connectivity
 sleep 3
     swanctl --load-all # Will wait from connection from outside.
     swanctl -i -c host-host


# VXLAN setup
# %all

	 ip link add vxlan0 type vxlan id 21 dev eth2 dstport 8472

         bridge fdb add 00:00:00:00:00:00 dst $REMOTE_IRISIP dev vxlan0 # dst is remote ip sec IP addr
        ip link set up vxlan0

     # openvswitch (IRIS)
# %all

        systemctl enable openvswitch; systemctl start openvswitch

        echo "export PATH=/usr/local/bin:/usr/share/openvswitch/scripts/:$PATH" >> /etc/bashrc
        export PATH=/usr/local/bin:/usr/share/openvswitch/scripts/:$PATH
        hash
        ovs-ctl start


         systemctl enable openvswitch; systemctl start openvswitch

         ovs-vsctl add-br ovs-br1


        if [ $VAGRANT_ROLE == "spoke" ]
	then
         	ovs-vsctl add-port ovs-br1 eth1 # For external NIC
	fi

        
         ovs-vsctl add-port ovs-br1 vxlan0

	ifconfig ovs-br1 $LOCALIP/24


cat /vagrant_data/supervisor >> /etc/supervisord.conf 
systemctl start supervisord

### /usr/local/bin/etherate -r -i vxlan0 &
