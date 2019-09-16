<?php
header ("Content-type: text/plain");
echo "#!ipxe\n";
$proxy = "http://juno.load:3128";
echo "set http-proxy " . $proxy . "\n";
echo "imgfree\n";
#echo "dhcp\n";
#echo "kernel http://ftp.ussg.iu.edu/linux/centos/7/os/x86_64/images/pxeboot/vmlinuz proxy=" . $proxy . " repo=http://ftp.ussg.iu.edu/linux/centos/7/os/x86_64 text rootpw --cleartext 123cithpc time zone US/Eastern install autopart\n";
echo "initrd http://ftp.ussg.iu.edu/linux/centos/7/os/x86_64/images/pxeboot/initrd.img\n";
echo "kernel http://ftp.ussg.iu.edu/linux/centos/7/os/x86_64/images/pxeboot/vmlinuz proxy=" . $proxy . " repo=http://ftp.ussg.iu.edu/linux/centos/7/os/x86_64 text ks=http://juno.load/ks.cfg\n";
#echo "vmlinuz initrd=initrd.img ks=http://juno.load/ks.cfg\n";
echo "boot\n";
?>
       
