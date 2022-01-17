server {
	listen 80 default_server;

	return 301 https://$host$request_uri;
}

server {
	listen 443 ssl http2;
	server_name m4_getenv_req(DOMAINS_OLD);

	include custom/ssl_params;

	# TODO: enable this once working.
	# rewrite ^/m4_getenv_req(OLD_WIKI_PATH)/(.*)$ https://m4_getenv_req(WIKI_DOMAIN)/$1;
	rewrite ^/m4_getenv_req(OLD_PARTDB_PATH)/(.*)$ https://m4_getenv_req(PARTDB_DOMAIN)/$1;
	rewrite ^/m4_getenv_req(OLD_SLACK_PATH)/(.*)$ https://m4_getenv_req(MISC_DOMAIN)/m4_getenv_req(SLACK_PATH)/$1;

	# temporary, while we get things figured out:
	location /m4_getenv_req(OLD_KEYCLOAK_PATH) {
		 include custom/proxy_params;
		 proxy_pass http://m4_getenv_req(WIREGUARD_NATHAN_IP):m4_getenv_req(KEYCLOAK_PORT)/auth;
	}

	# TODO: remove this once new wiki works.
	location /m4_getenv_req(OLD_WIKI_PATH) {
		 include custom/proxy_params;
		 proxy_pass http://m4_getenv_req(WIREGUARD_NATHAN_IP):m4_getenv_req(WIKI_INTERMEDIATE_PORT);
	}
}

server {
	listen 443 ssl http2;
	server_name m4_getenv_req(WIKI_DOMAIN);

	gzip on;
	gzip_types application/javascript text/css;
	gzip_proxied expired no-cache no-store private;

	client_max_body_size 128M;

	include custom/ssl_params;

	location / {
		include custom/proxy_params;
		proxy_pass http://m4_getenv_req(WIREGUARD_NATHAN_IP):m4_getenv_req(WIKI_INTERMEDIATE_PORT);
	}
}


server {
	listen 443 ssl http2;
	server_name m4_getenv_req(PARTDB_DOMAIN);

	gzip on;
	gzip_types application/javascript text/css;
	gzip_proxied expired no-cache no-store private;

	client_max_body_size 128M;

	include custom/ssl_params;

	location / {
		include custom/proxy_params;
		proxy_pass http://m4_getenv_req(WIREGUARD_NATHAN_IP):m4_getenv_req(PARTDB_INTERMEDIATE_PORT);
	}
}

server {
	listen 443 ssl http2;
	server_name m4_getenv_req(MISC_DOMAIN);

	gzip on;
	gzip_types application/javascript text/css;
	gzip_proxied expired no-cache no-store private;

	include custom/ssl_params;

	location /m4_getenv_req(KEYCLOAK_PATH) {
		include custom/proxy_params;
		proxy_pass http://m4_getenv_req(WIREGUARD_NATHAN_IP):m4_getenv_req(KEYCLOAK_PORT)/auth;
	}

	location /m4_getenv_req(SLACK_PATH)/ {
		include custom/proxy_params;
		proxy_pass http://m4_getenv_req(WIREGUARD_NATHAN_IP):m4_getenv_req(SLACK_EXPORT_VIEWER_PORT)/;
		sub_filter_last_modified on;
		sub_filter_once off;
		sub_filter 'href="/' 'href="/m4_getenv_req(SLACK_PATH)/';
	}
}
