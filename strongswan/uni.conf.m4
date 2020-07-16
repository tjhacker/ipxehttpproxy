connections {
ab {
  version = 2
  mobike = no
  local_addrs = __LOCAL_FQDN
  ifdef(`__REMOTE_FQDN', remote_addrs = __REMOTE_FQDN)
  aggressive = yes

  local {
    auth = pubkey	
    ifdef(`__LOCAL_FQDN', id = __LOCAL_FQDN)
    certs = __LOCAL_CERT
  }
  remote {
    auth = pubkey
    ifdef(`__REMOTE_FQDN', id = __REMOTE_FQDN)
    ifdef(`__REMOTE_CERT', certs = __REMOTE_CERT)
  }
  children {
   host-host {

    ifdef(`__LOCALIP_TS', local_ts = __LOCALIP_TS)
    ##ifdef(`__REMOTEIP_TS', remote_ts = __REMOTEIP_TS)
    remote_ts = __REMOTEIP_TS
    rekey_time = 5400
    esp_proposals = aes128gcm128-x25519
  }
 }
 }
}

