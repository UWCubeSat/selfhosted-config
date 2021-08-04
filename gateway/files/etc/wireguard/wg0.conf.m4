[Interface]
Address = m4_getenv_req(WIREGUARD_GATEWAY_IP)
ListenPort = 51820
PrivateKey = m4_getenv_req(WIREGUARD_GATEWAY_PRIVKEY)

[Peer]
PublicKey = m4_getenv_req(WIREGUARD_NATHAN_PUBKEY)
AllowedIPs = m4_getenv_req(WIREGUARD_NATHAN_IP)
