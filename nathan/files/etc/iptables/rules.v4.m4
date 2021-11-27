*filter
:INPUT DROP [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]

# Outgoing DNS from VMs, I guess? This may not be necessary
-A INPUT -i hslbr -p udp -m udp --dport 53 -j ACCEPT
-A INPUT -i hslbr -p tcp -m tcp --dport 53 -j ACCEPT

# I'm not totally sure if these lines are necessary; perhaps used by libvirt for VM DHCP?
# TODO: one day use a more unique name for the interface to lessen chance of it being wrong
-A INPUT -i hslbr -p udp -m udp --dport 67 -j ACCEPT
-A INPUT -i hslbr -p tcp -m tcp --dport 67 -j ACCEPT
-A OUTPUT -o hslbr -p udp -m udp --dport 68 -j ACCEPT
-A OUTPUT -o hslbr -p udp -m udp --dport 68 -j ACCEPT

-A INPUT -p icmp -m icmp --icmp-type 3 -j ACCEPT
-A INPUT -p icmp -m icmp --icmp-type 11 -j ACCEPT
-A INPUT -p icmp -m icmp --icmp-type 12 -j ACCEPT
-A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
# Probably not necessary:
-A INPUT -p udp -m udp --sport 67 --dport 68 -j ACCEPT
-A INPUT -i lo -j ACCEPT

# Allow connections that are already established to continue
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Ports open on host
# SSH
-A INPUT -p tcp --dport 22 -j ACCEPT
# Keycloak
-A INPUT -p tcp --dport m4_getenv_req(KEYCLOAK_PORT) -j ACCEPT
# Slack export viewer
-A INPUT -p tcp --dport m4_getenv_req(SLACK_EXPORT_VIEWER_PORT) -j ACCEPT
# Minecraft
-A INPUT -p tcp --dport 25565 -j ACCEPT
-A INPUT -p udp --dport 25565 -j ACCEPT
COMMIT

*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]

###########################################
## IF YOU'RE ADDING A NEW VM, LOOK HERE! ##
###########################################

# SSH port forwarding to VMs:
-A PREROUTING -p tcp --dport m4_getenv_req(JEVIN_PUBLIC_SSH_PORT) -j DNAT --to-destination m4_getenv_req(VIRT_JEVIN_IP):22
-A PREROUTING -p tcp --dport m4_getenv_req(KAVEL_PUBLIC_SSH_PORT) -j DNAT --to-destination m4_getenv_req(VIRT_KAVEL_IP):22
-A PREROUTING -p tcp --dport m4_getenv_req(PARTDB_PUBLIC_SSH_PORT) -j DNAT --to-destination m4_getenv_req(VIRT_PARTDB_IP):22
-A PREROUTING -p tcp --dport m4_getenv_req(WIKI_PUBLIC_SSH_PORT) -j DNAT --to-destination m4_getenv_req(VIRT_WIKI_IP):22

# Wiki HTTP:
-A PREROUTING -p tcp --dport m4_getenv_req(WIKI_INTERMEDIATE_PORT) -j DNAT --to-destination m4_getenv_req(VIRT_WIKI_IP):80

# PartDB HTTP:
-A PREROUTING -p tcp --dport m4_getenv_req(PARTDB_INTERMEDIATE_PORT) -j DNAT --to-destination m4_getenv_req(VIRT_PARTDB_IP):80

# Most important postrouting rule: Masquerade traffic leaving VMs as coming from the host
-A POSTROUTING -s m4_getenv_req(VIRT_BASE_IP).0/24 ! -d m4_getenv_req(VIRT_BASE_IP).0/24 -j MASQUERADE
COMMIT

*mangle
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
# No idea what's going on here
-A POSTROUTING -o hslbr -p udp -m udp --dport 68 -j CHECKSUM --checksum-fill
COMMIT

*raw
:PREROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
COMMIT
