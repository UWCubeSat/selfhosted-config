*filter
:INPUT DROP [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]

# Outgoing DNS from VMs, I guess? This may not be necessary
-A INPUT -i hslbr0 -p udp -m udp --dport 53 -j ACCEPT
-A INPUT -i hslbr0 -p tcp -m tcp --dport 53 -j ACCEPT

# I'm not totally sure if these lines are necessary; perhaps used by libvirt for VM DHCP?
# TODO: one day use a more unique name for the interface to lessen chance of it being wrong
-A INPUT -i hslbr0 -p udp -m udp --dport 67 -j ACCEPT
-A INPUT -i hslbr0 -p tcp -m tcp --dport 67 -j ACCEPT
-A OUTPUT -o hslbr0 -p udp -m udp --dport 68 -j ACCEPT
-A OUTPUT -o hslbr0 -p udp -m udp --dport 68 -j ACCEPT

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
-A INPUT -p tcp --dport m4_getenv_req(HOST_SSH_PORT) -j ACCEPT
-A INPUT -p tcp --dport 25565 -j ACCEPT
-A INPUT -p udp --dport 25565 -j ACCEPT
COMMIT

*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]

# Root SSH port forwarding. Rather than modify SSH config, we let it listen on port 22 as normal,
# and then redirect requests from the public port as necessary.
-A PREROUTING -p tcp --dport m4_getenv_req(HOST_SSH_PORT) -j REDIRECT --to-ports 22
# To be safe until testing the above rule:
-A INPUT -p tcp --dport 22 -j ACCEPT

###########################################
## IF YOU'RE ADDING A NEW VM, LOOK HERE! ##
###########################################

# SSH port forwarding to VMs:
-A PREROUTING -p tcp --dport m4_getenv_req(VIRT_JEVIN_SSH_PORT) -j DNAT --to-destination m4_getenv_req(VIRT_JEVIN_IP):22
-A PREROUTING -p tcp --dport m4_getenv_req(VIRT_KAVEL_SSH_PORT) -j DNAT --to-destination m4_getenv_req(VIRT_KAVEL_IP):22
-A PREROUTING -p tcp --dport m4_getenv_req(VIRT_PARTDB_SSH_PORT) -j DNAT --to-destination m4_getenv_req(VIRT_PARTDB_IP):22
-A PREROUTING -p tcp --dport m4_getenv_req(VIRT_WIKI_SSH_PORT) -j DNAT --to-destination m4_getenv_req(VIRT_WIKI_IP):22

# Wiki HTTP:
-A PREROUTING -p tcp --dport 8001 -j DNAT --to-destination m4_getenv_req(VIRT_WIKI_IP):80

# PartDB HTTP:
-A PREROUTING -p tcp --dport 8081 -j DNAT --to-destination m4_getenv_req(VIRT_PARTDB_IP):80

# These two probably aren't necessary
-A POSTROUTING -s m4_getenv_req(VIRT_BASE_IP).0/24 -d 224.0.0.0/24 -j RETURN
-A POSTROUTING -s m4_getenv_req(VIRT_BASE_IP).0/24 -d 255.255.255.255/32 -j RETURN

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
-A POSTROUTING -o hslbr0 -p udp -m udp --dport 68 -j CHECKSUM --checksum-fill
COMMIT

*raw
:PREROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
COMMIT
