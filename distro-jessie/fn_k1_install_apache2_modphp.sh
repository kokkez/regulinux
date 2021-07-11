# ------------------------------------------------------------------------------
# install apache2 web server with mod_php
# ------------------------------------------------------------------------------

install_apache2_modphp() {
	Pkg.requires apache2 libapache2-mod-php5 php5 php5-mysqlnd

	# adjust expose_php & date.timezone in all php.ini
	sed -ri /etc/php5/*/php.ini \
		-e 's|^(expose_php =) On|\1 Off|' \
		-e "s|^;(date\.timezone =).*|\1 '${TIME_ZONE}'|"

	# activating ports on firewall
	firewall_allow "http"

	Msg.info "Configuration of mod-php5 completed!"
}	# end install_apache2_modphp
