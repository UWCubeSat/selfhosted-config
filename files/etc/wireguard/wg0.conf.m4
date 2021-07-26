[Interface]
Address = m4_getenv_req(WIREGUARD_SELF_IP)
PrivateKey = m4_getenv_req(WIREGUARD_PRIVKEY)

[Peer]
Endpoint = m4_getenv_req(WIREGUARD_GATEWAY)
PublicKey = m4_getenv_req(WIREGUARD_GATEWAY_PUBKEY)
PersistentKeepalive = 25
AllowedIPs = m4_getenv_req(WIREGUARD_BASE_IP).1/24
