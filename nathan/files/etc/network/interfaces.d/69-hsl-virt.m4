auto hslbr
iface hslbr inet static
	bridge_ports none
	bridge_stp off
	address m4_getenv_req(VIRT_BASE_IP).1
	netmask 255.255.255.0
