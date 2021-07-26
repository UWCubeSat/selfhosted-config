<network>
  <name>default</name>
  <uuid>682116bf-a413-4d78-b0f5-46c5fb43ddd3</uuid>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr0' stp='on' delay='0'/>
  <mac address='52:54:00:32:7d:d5'/>
  <ip address='m4_getenv_req(VIRT_BASE_IP).1' netmask='255.255.255.0'>
    <dhcp>
      <range start='m4_getenv_req(VIRT_BASE_IP).2' end='m4_getenv_req(VIRT_BASE_IP).254'/>
      <host mac='m4_getenv_req(VIRT_JEVIN_MAC)' name='jevin' ip='m4_getenv_req(VIRT_JEVIN_IP)'/>
      <host mac='m4_getenv_req(VIRT_KAVEL_MAC)' name='kavel' ip='m4_getenv_req(VIRT_KAVEL_IP)'/>
      <host mac='m4_getenv_req(VIRT_PARTDB_MAC)' name='partdb' ip='m4_getenv_req(VIRT_PARTDB_IP)'/>
      <host mac='m4_getenv_req(VIRT_WIKI_MAC)' name='wiki' ip='m4_getenv_req(VIRT_WIKI_IP)'/>
    </dhcp>
  </ip>
</network>
