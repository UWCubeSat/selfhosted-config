#!/bin/bash

echo
echo 'STARTING Nathan'
echo

source remotely.sh
remotely_go

source go-networking.sh
source go-virt.sh
source go-sso.sh
# source go-minecraft.sh

echo
echo 'DONE with Nathan'
echo
