keycloak_dir := keycloak-$(KEYCLOAK_VERSION)
keycloak_zip := keycloak-$(KEYCLOAK_VERSION).zip
keycloak_url := https://github.com/keycloak/keycloak/releases/download/$(KEYCLOAK_VERSION)/keycloak-$(KEYCLOAK_VERSION).zip

$(keycloak_dir): $(keycloak_zip)
	unzip -D $(keycloak_zip) # it automatically unzips to the right directory name

$(keycloak_zip):
	curl -Lo $@ '$(keycloak_url)'
