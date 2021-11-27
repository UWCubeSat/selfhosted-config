#!/bin/bash

echo
echo 'STARTING slack message search'
echo

source remotely.sh
remotely_go

remotely apt-get install -y rsync python3-pip python3-click python3-flask python3-markdown2

remotely id slack 2>/dev/null || remotely useradd -md /home/slack slack
remotely sudo -u slack pip3 install --user slack-export-viewer

upload /etc/systemd
remotely systemctl daemon-reload
remotely systemctl restart slack-export-viewer-custom
