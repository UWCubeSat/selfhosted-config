#!/bin/bash

echo
echo 'STARTING sso'
echo

source remotely.sh
remotely_go

env_req KEYCLOAK_VERSION

remotely apt-get install -y rsync default-jre unzip make

remotely id keycloak 2>/dev/null || remotely useradd -md /home/keycloak keycloak
upload /home/keycloak -og --chown keycloak:keycloak
remotely sudo -u keycloak make -C /home/keycloak "KEYCLOAK_VERSION=$KEYCLOAK_VERSION"
remotely sudo -u keycloak ln -sfn /home/keycloak/keycloak-$KEYCLOAK_VERSION /home/keycloak/keycloak-active

upload /etc/systemd/system/keycloak-custom.service

remotely systemctl daemon-reload
remotely systemctl restart keycloak-custom
remotely systemctl enable keycloak-custom
