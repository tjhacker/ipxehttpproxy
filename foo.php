<?php
header ("Content-type: text/plain");
echo "#!ipxe\n";
echo "imgfree\n";
$proxy = "http://juno.load:3128";
echo "set http-proxy " . $proxy . "\n";
echo "menu Please choose an image to load on this system.\n";
echo "item --key t truenas (t) Install TrueNAS server\n";
echo "item --key f freenas (f) Install FreeNAS server\n";
echo "item --key c centos7 (c) Install CentOS7\n";
echo "choose target\n";
#echo "dhcp\n";
echo "show target\n";
echo "goto \${target}\n";
echo "exit\n";
#echo "kernel http://ftp.ussg.iu.edu/linux/centos/7/os/x86_64/images/pxeboot/vmlinuz proxy=" . $proxy . " repo=http://ftp.ussg.iu.edu/linux/centos/7/os/x86_64 text rootpw --cleartext 123cithpc time zone US/Eastern install autopart\n";
echo ":centos7\n";
echo "#CentOS7\n";
echo "kernel http://ftp.ussg.iu.edu/linux/centos/7/os/x86_64/images/pxeboot/vmlinuz proxy=" . $proxy . " text repo=http://ftp.ussg.iu.edu/linux/centos/7/os/x86_64 text ks=http://juno.load/ks.cfg\n";
echo "initrd http://ftp.ussg.iu.edu/linux/centos/7/os/x86_64/images/pxeboot/initrd.img\n";
#echo "vmlinuz initrd=initrd.img ks=http://juno.load/ks.cfg\n";
echo "boot\n";

echo ":truenas\n";
echo "set root-path nfs://192.7.7.4/truenas\n";
echo "chain nfs://192.7.7.4/truenas/boot/pxeboot\n";

?>
       
