#!/bin/bash

echo
echo 'STARTING virt'
echo

source remotely.sh
remotely_go

if ! remotely ip link show hslbr >/dev/null
then
    echo 'hslbr does not exist! Run networking first!' >&2
    exit 1
fi

upload /etc/dnsmasq.conf
upload /etc/dnsmasq-hosts

remotely apt-get install -y rsync qemu-kvm libvirt-daemon-system dnsmasq

remotely systemctl stop dnsmasq
remotely systemctl start libvirtd virtlogd
remotely systemctl enable libvirtd virtlogd dnsmasq

upload /etc/libvirt-custom

remotely virsh define /etc/libvirt-custom/kavel.xml
remotely virsh define /etc/libvirt-custom/partdb.xml
remotely virsh define /etc/libvirt-custom/wiki.xml
remotely virsh autostart kavel
remotely virsh autostart partdb
remotely virsh autostart wiki

echo
echo 'DONE with virt'
echo
