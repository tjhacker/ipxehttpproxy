<?php
header ("Content-type: text/plain");
$outfile = "/tmp/test.txt";
if ( $_GET["selection"] || $_GET["param"] ) {
	$selection = $_GET["selection"];
	echo $selection;
}
$dhcp_opts = fopen("/var/dhcpopts/dhcpopts", "w");
if ($dhcp_opts == false) {
	echo ("Can't open DHCP opts file\n");
	exit();
}
$dhcp_opts_string = "17,nfs://192.7.7.4/" . $selection;
fwrite($dhcp_opts, $dhcp_opts_string);

$handle = fopen($outfile, 'w');
fwrite($handle, $selection);
fclose($handle);

?>
       
