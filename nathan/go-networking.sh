#!/bin/bash

echo
echo 'STARTING networking'
echo

source remotely.sh
remotely_go

remotely apt-get install -y rsync wireguard bridge-utils fail2ban

upload /etc/wireguard -p --chmod 600
upload /etc/iptables

upload /etc/network/interfaces.d/69-hsl-virt
remotely ifup hslbr

upload /etc/systemd/system/iptables-custom.service
upload /etc/sysctl.d/69-ipv4-forward.conf
remotely sysctl --system

remotely systemctl daemon-reload
remotely systemctl reload wg-quick@wg0 || true
remotely systemctl start wg-quick@wg0 iptables-custom
remotely systemctl enable wg-quick@wg0 iptables-custom
remotely systemctl start fail2ban
remotely systemctl enable fail2ban

echo
echo 'DONE with networking'
echo
