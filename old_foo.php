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
echo "item --key p pfs (p) Install pfSense\n";
echo "choose target\n";
#echo "dhcp\n";
echo "show target\n";
echo "goto \${target}\n";
echo "exit\n";
echo ":centos7\n";
echo "#CentOS7\n";
echo "kernel http://ftp.ussg.iu.edu/linux/centos/7/os/x86_64/images/pxeboot/vmlinuz proxy=" . $proxy . " text repo=http://ftp.ussg.iu.edu/linux/centos/7/os/x86_64 text ks=http://juno.load/ks.cfg\n";
echo "initrd http://ftp.ussg.iu.edu/linux/centos/7/os/x86_64/images/pxeboot/initrd.img\n";
echo "boot\n";

echo ":truenas\n";
$post_cmd = "imgfetch http://juno.load/dhcp_opt.php?selection=\${target}\n";
echo $post_cmd;
echo "imgfree dhcp_opt.php\n";
echo "dhcp\n";
echo "sleep 4\n";
echo ":retry_truenas_nfs\n";
echo "imgfetch --timeout 1000000 nfs://192.7.7.4/truenas/boot/pxeboot || goto retry_truenas_nfs\n";
echo "echo Image loaded.\n";
echo "boot pxeboot\n";


echo ":freenas\n";
$post_cmd = "imgfetch http://juno.load/dhcp_opt.php?selection=\${target}\n";
echo $post_cmd;
echo "imgfree dhcp_opt.php\n";
echo "dhcp\n";
echo "sleep 4\n";
echo ":retry_freenas_nfs\n";
echo "imgfetch --timeout 1000000 nfs://192.7.7.4/freenas/boot/pxeboot || goto retry_freenas_nfs\n";
echo "echo Image loaded.\n";
echo "boot pxeboot\n";


echo ":pfs\n";
$post_cmd = "imgfetch http://juno.load/dhcp_opt.php?selection=\${target}\n";
echo $post_cmd;
echo "imgfree dhcp_opt.php\n";
echo "dhcp\n";
echo "sleep 4\n";
echo ":retry_pfs_nfs\n";
echo "imgfetch --timeout 1000000 nfs://192.7.7.4/pfs/boot/pxeboot || goto retry_pfs_nfs\n";
echo "echo Image loaded.\n";
echo "boot pxeboot\n";
?>
       
