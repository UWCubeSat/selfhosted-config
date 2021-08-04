#!/bin/bash

echo
echo 'STARTING gateway'
echo

source remotely.sh
remotely_go

source go-networking.sh
source go-web-server.sh

echo
echo 'DONE with gateway'
echo
