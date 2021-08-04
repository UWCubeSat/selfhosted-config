#!/bin/bash

echo
echo 'STARTING web server'
echo

source remotely.sh
remotely_go

env_req LETSENCRYPT_EMAIL
env_req DOMAIN_CURRENT
env_req DOMAINS_OLD

remotely apt-get install -y rsync nginx certbot

upload /etc/nginx/custom
upload /etc/nginx/sites-enabled --delete

upload /build/letsencrypt
upload /etc/letsencrypt/renewal-hooks
remotely systemctl stop nginx
remotely make -C /build/letsencrypt \
	 "LETSENCRYPT_CERT_NAME=hsl" \
	 "LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL" \
	 "LETSENCRYPT_DOMAINS=$DOMAIN_CURRENT $DOMAINS_OLD"

remotely systemctl start nginx
remotely systemctl enable nginx

echo
echo 'DONE with web server'
echo
