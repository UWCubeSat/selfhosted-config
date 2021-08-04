*filter
:INPUT DROP [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
# TODO: it would be good to set FORWARD DROP here, to prevent arbitrary packets somehow getting into wireguard?
-A INPUT -i lo -j ACCEPT
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -m icmp --icmp-type 3 -j ACCEPT
-A INPUT -p icmp -m icmp --icmp-type 11 -j ACCEPT
-A INPUT -p icmp -m icmp --icmp-type 12 -j ACCEPT
-A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
-A INPUT -p udp -m udp --sport 67 --dport 68 -j ACCEPT

# SSH
-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
# HTTP/S
-A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
# Wireguard
-A INPUT -p tcp -m tcp --dport 51820 -j ACCEPT
-A INPUT -p udp -m udp --dport 51820 -j ACCEPT
COMMIT

*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]

# SSH to the server itself
-A PREROUTING -p tcp --dport m4_getenv_req(NATHAN_PUBLIC_SSH_PORT) -j DNAT --to-destination m4_getenv_req(WIREGUARD_NATHAN_IP):22
# Miiiinecraft
-A PREROUTING -p tcp --dport 25565 -j DNAT --to-destination m4_getenv_req(WIREGUARD_NATHAN_IP)

# VM SSHs
-A PREROUTING -p tcp --dport m4_getenv_req(KAVEL_PUBLIC_SSH_PORT) -j DNAT --to-destination m4_getenv_req(WIREGUARD_NATHAN_IP)
-A PREROUTING -p tcp --dport m4_getenv_req(WIKI_PUBLIC_SSH_PORT) -j DNAT --to-destination m4_getenv_req(WIREGUARD_NATHAN_IP)
-A PREROUTING -p tcp --dport m4_getenv_req(PARTDB_PUBLIC_SSH_PORT) -j DNAT --to-destination m4_getenv_req(WIREGUARD_NATHAN_IP)

# Critical postrouting rule: Masquerade traffic heading through Wireguard
-A POSTROUTING -d m4_getenv_req(WIREGUARD_NATHAN_IP) -j MASQUERADE
COMMIT
