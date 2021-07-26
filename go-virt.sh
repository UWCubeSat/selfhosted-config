#!/bin/bash

source remotely.sh
remotely_go

remotely apt-get install -y rsync qemu-kvm libvirt-daemon-system

upload /etc/libvirt-custom

remotely virsh net-define /etc/libvirt-custom/default-network.xml
# TODO: can we do this without interruption?
remotely virsh net-destroy default # doesn't actually "destroy" persistent networks -- just stops them
remotely virsh net-start default

remotely define /etc/libvirt-custom/kavel-machine.xml
remotely define /etc/libvirt-custom/partdb-machine.xml
remotely define /etc/libvirt-custom/wiki-machine.xml
remotely virsh autostart kavel
remotely virsh autostart partdb
remotely virsh autostart wiki
