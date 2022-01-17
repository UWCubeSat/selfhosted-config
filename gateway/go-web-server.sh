#!/bin/bash

echo
echo 'STARTING web server'
echo

source remotely.sh
remotely_go

env_req LETSENCRYPT_EMAIL
env_req DOMAINS_OLD

remotely apt-get install -y rsync nginx certbot

upload /etc/nginx/custom
upload /etc/nginx/sites-enabled --delete --exclude '*.m4'
remotely nginx -t

upload /etc/letsencrypt/renewal-hooks
remotely systemctl stop nginx
remotely certbot certonly --non-interactive --agree-tos --standalone \
	 --cert-name hsl -m "$LETSENCRYPT_EMAIL" -d ${DOMAINS_OLD// /,},$WIKI_DOMAIN,$PARTDB_DOMAIN,$MISC_DOMAIN

remotely systemctl start nginx
remotely systemctl enable nginx

echo
echo 'DONE with web server'
echo
