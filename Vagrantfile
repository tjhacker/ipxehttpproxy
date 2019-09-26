# -*- mode: ruby -*-
# vi: set ft=ruby :

LOCALIP = "192.168.33.10"
IRISIP = "192.100.42.20"


# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "generic/centos7"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
#   config.vm.network "private_network", ip: "192.168.33.10", virtualbox__intnet: "pxe test"
   config.vm.network "private_network", ip: LOCALIP, virtualbox__intnet: "pxe test"
config.vm.network "private_network", ip: IRISIP, virtualbox__intnet: "irisnet"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.

 # Hacker - this is for creating the jumphost we need to boostrap a private cloud
   config.vm.provision "shell", inline: <<-SHELL
	
	
	export LOCALIP="192.168.33.10"


	yum -y update
	yum -y install dnsmasq dnsmasq-utils tftp-server tftp openvswitch openvswitch-contoller syslinux-tftpboot ipxe-bootimgs git
	
	# create patched ipxe with HTTP proxy support
	cd /usr/local/src; git clone git://git.ipxe.org/ipxe.git; cd ipxe; git clone https://github.com/tjhacker/ipxehttpproxy.git
	cd /usr/local/src/ipxe
	patch -p1 < ipxehttpproxy/proxypatch.p
	cp ipxehttpproxy/embedded.pxe src/embedded.pxe
	cd src
	
	yum -y install xz-devel genisoimage
	
	make EMBED=embedded.pxe -j 4

	cp /usr/local/src/ipxe/src/bin/undionly.kpxe /var/lib/tftpboot

	systemctl stop NetworkManager
	firewall-cmd --new-zone=juno --permanent
	firewall-cmd --reload
	firewall-cmd --zone=juno --change-interface=eth1 
	firewall-cmd --runtime-to-permanent
	firewall-cmd --zone=juno --add-service dhcp --permanent
	firewall-cmd --zone=juno --add-service tftp --permanent
	firewall-cmd --zone=juno --add-service dns --permanent
	firewall-cmd --zone=juno --add-service squid --permanent
	firewall-cmd --add-masquerade --permanent
	firewall-cmd --reload
	systemctl start NetworkManager

#	DNS=`fgrep -m 1 nameserver /etc/resolv.conf | sed 's/nameserver //'`
#	sed -i "s/$DNS/$LOCALIP/" /etc/resolv.conf
	nmcli con mod "System eth0" +ipv4.dns $LOCALIP
	nmcli con mod "System eth0" ipv4.ignore-auto-dns yes
	 nmcli con up "System eth0"


	dnsmasq --enable-tftp --tftp-root=/var/lib/tftpboot --interface=eth1 --dhcp-range=192.168.33.20,192.168.33.25,255.255.255.0  --dhcp-boot=undionly.kpxe --address=/juno.load/$LOCALIP --server=8.8.4.4


		
	yum -y install lighttpd php mod_fcgid lighttpd-fastcgi mod_fastcgi 
	sed -i 's/server.use-ipv6 = "enable"/server.use-ipv6 = "disable"/' /etc/lighttpd/lighttpd.conf
	# Add fastCGI conf to lighttpd 
	cat /usr/local/src/ipxe/ipxehttpproxy/fastcgi.conf_addition >> /etc/lighttpd/conf.d/fastcgi.conf
	cp /usr/local/src/ipxe/ipxehttpproxy/foo.php /var/www/lighttpd/foo.php
	 mkdir /var/www/localhost
	 cp /etc/php.ini /var/www/localhost
	sed -i "s:;cgi.fix_pathinfo:cgi.fix_pathinfo:" /var/www/localhost/php.ini
	sed -i 's:#include "conf.d/fastcgi.conf:include "conf.d/fastcgi.conf:' /etc/lighttpd/modules.conf



	systemctl enable lighttpd; systemctl start lighttpd


	yum -y install squid
	sed -i "s:\#cache_dir ufs /var/spool/squid 100 16 256:cache_dir ufs /var/spool/squid 100000 16 256:" /etc/squid/squid.conf	 
	echo "maximum_object_size 40 GB" >> /etc/squid/squid.conf

	squid -z
	sleep 5; systemctl enable squid; systemctl start squid


	cp /usr/local/src/ipxe/ipxehttpproxy/ks.cfg /var/www/lighttpd/ks.cfg

     # openvswitch (IRIS)

         cd /usr/local/src
        wget https://rdoproject.org/repos/rdo-release.rpm
        rpm -i rdo-release.rpm
        yum -y install openvswitch libibverbs
        systemctl enable openvswitch; systemctl start openvswitch

        echo "export PATH=/usr/local/bin:/usr/share/openvswitch/scripts/:$PATH" >> /etc/bashrc
        export PATH=/usr/local/bin:/usr/share/openvswitch/scripts/:$PATH
        hash
        ovs-ctl start


         systemctl enable openvswitch; systemctl start openvswitch

         ovs-vsctl add-br ovs-br1
         ovs-vsctl add-port ovs-br1 eth2
         ifconfig ovs-br1 192.100.42.5/24




  #   apt-get update
  #   apt-get install -y apache2
   SHELL
end
