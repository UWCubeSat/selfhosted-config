interface=hslbr
except-interface=lo
port=0
dhcp-range=m4_getenv_req(VIRT_BASE_IP).2,m4_getenv_req(VIRT_BASE_IP).254
dhcp-hostsfile=/etc/dnsmasq-hosts
dhcp-option=option:dns-server,1.1.1.1
