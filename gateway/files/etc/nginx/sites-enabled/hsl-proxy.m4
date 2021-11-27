server {
	listen 80 default_server;

	return 301 https://$host$request_uri;
}

server {
	listen 443 ssl http2;
	server_name m4_getenv_req(DOMAINS_OLD);

	return 301 https://m4_getenv_req(DOMAIN_CURRENT)$request_uri;

	include custom/ssl_params;
}

server {
	listen 443 ssl http2;
	server_name m4_getenv_req(DOMAIN_CURRENT);

	gzip on;
	gzip_types application/javascript text/css;
	gzip_proxied expired no-cache no-store private;

	client_max_body_size 128M;

	location /wiki {
		include custom/proxy_params;
		proxy_pass http://m4_getenv_req(WIREGUARD_NATHAN_IP):m4_getenv_req(WIKI_INTERMEDIATE_PORT);
	}

	location /partdb {
		include custom/proxy_params;
		proxy_pass http://m4_getenv_req(WIREGUARD_NATHAN_IP):m4_getenv_req(PARTDB_INTERMEDIATE_PORT);
	}

	location /keycloak {
		include custom/proxy_params;
		proxy_pass http://m4_getenv_req(WIREGUARD_NATHAN_IP):m4_getenv_req(KEYCLOAK_PORT)/auth;
	}

	location /slack-history {
		include custom/proxy_params;
		proxy_pass http://m4_getenv_req(WIREGUARD_NATHAN_IP):m4_getenv_req(SLACK_EXPORT_VIEWER_PORT)/;
		proxy_redirect default;
		sub_filter_last_modified on;
		sub_filter_once off;
		sub_filter 'href="/' 'href="/slack-history/';
	}

	include custom/ssl_params;
}
