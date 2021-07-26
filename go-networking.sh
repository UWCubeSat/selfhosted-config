#!/bin/bash

source remotely.sh
remotely_go

remotely apt-get install -y rsync wireguard

upload /etc/wireguard -p --chmod 600
upload /etc/iptables

upload /etc/systemd/system/iptables-custom.service
upload /etc/sysctl.d/69-ipv4-forward.conf
remotel sysctl --system

remotely systemctl daemon-reload
remotely systemctl reload wg-quick@wg0 || true
remotely systemctl start wg-quick@wg0 iptables-custom
remotely systemctl enable wg-quick@wg0 iptables-custom

echo
echo 'DONE with networking'
echo
