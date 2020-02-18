# Ensure strongswan installed
yum -y install strongswan

strongswan pki --gen --outform pem > CAKey.key
strongswan pki --self --in CAKey.key --dn "C=US,ST=Indiana,L=West Lafayette,O=Purdue University,emailAddress=tjhacker@purdue.edu,CN=strongSwan CA" --ca --outform pem > CA.crt
strongswan pki --gen --outform pem > hostSunKey.key
strongswan pki --gen --outform pem > hostMoonKey.key
strongswan pki --issue --in hostSunKey.key --type priv --cacert CA.crt --cakey CAKey.key --dn "C=US,ST=Indiana,L=West Lafayette,O=Purdue University,emailAddress=tjhacker@purdue.edu,CN=sun.localdomain,OU=CIT" --san sun.localdomain --outform pem > hostSunCert.crt
strongswan pki --issue --in hostMoonKey.key --type priv --cacert CA.crt --cakey CAKey.key --dn "C=US,ST=Indiana,L=West Lafayette,O=Purdue University,emailAddress=tjhacker@purdue.edu,CN=moon.localdomain,OU=CIT" --san moon.localdomain --outform pem > hostMoonCert.crt
