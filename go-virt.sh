#!/bin/bash

source remotely.sh
remotely_go

remotely apt-get install -y rsync qemu-kvm libvirt-daemon-system

upload /etc/libvirt-custom

remotely virsh net-define /etc/libvirt-custom/hsl-network.xml
# TODO: can we do this without interruption?
remotely virsh net-destroy hsl 2>/dev/null || true # doesn't actually "destroy" persistent networks -- just stops them
remotely virsh net-start hsl

remotely virsh define /etc/libvirt-custom/kavel.xml
remotely virsh define /etc/libvirt-custom/partdb.xml
remotely virsh define /etc/libvirt-custom/wiki.xml
remotely virsh autostart kavel
remotely virsh autostart partdb
remotely virsh autostart wiki
