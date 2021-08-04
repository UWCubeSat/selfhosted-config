[Interface]
Address = m4_getenv_req(WIREGUARD_NATHAN_IP)
PrivateKey = m4_getenv_req(WIREGUARD_NATHAN_PRIVKEY)

[Peer]
Endpoint = m4_getenv_req(WIREGUARD_GATEWAY_PUBLIC_IP)
PublicKey = m4_getenv_req(WIREGUARD_GATEWAY_PUBKEY)
PersistentKeepalive = 25
AllowedIPs = m4_getenv_req(WIREGUARD_BASE_IP).1/24
