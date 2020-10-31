# ------------------------------------------------------------------------------
# install varnish 5.2
# ------------------------------------------------------------------------------

install_varnish() {
	# abort if package was already installed
	is_installed "varnish" && {
		msg_alert "Varnish is already installed..."
		return
	}

	# check the presence of apache2
	is_installed "apache2-bin" || {
		msg_alert "apache2 is NOT installed..."
		return
	}

	msg_info "Installing Varnish..."
	pkg_install varnish

	msg_info "Configuring Varnish..."

	# configuring apache2
	# replace port '80' with '8008' in configuration file "ports.conf"
	# and all virtual host files under the "sites-available" directory
	cd /etc/apache2
	sed -i 's| 80$| 127.0.0.1:80|g' ports.conf
#	sed -i 's|80>|8008>|g' sites-available/*

	# configuring apache2 for SSL
	# load all the necessary modules
	a2enmod ssl proxy proxy_balancer proxy_http
	cmd apachectl configtest
	local T P=sites-available/default-ssl.conf I=$(cmd hostname -s)
	T="\t\t########################################################################
		# varnish global settings
		SetEnvIf			X-Forwarded-Proto https HTTPS=on

		ProxyPreserveHost	On
		ProxyRequests		Off
		ProxyPass			/	http://${I}:80/
		ProxyPassReverse	/	http://${I}:80/

		RequestHeader		set X-Forwarded-Port expr=%{SERVER_PORT}
		RequestHeader		set X-Forwarded-Proto expr=%{REQUEST_SCHEME}
		########################################################################"
	grep -q 'varnish' ${P} || {
		perl -i -pe "s|</VirtualHost>|${T}\n\t</VirtualHost>|g" ${P}
	}

	# backup default varnish config file
	backup_file /etc/varnish/default.vcl
	# change port in 'backend default' section, line 18
	sed -i 's|"8080"|"80"|g' /etc/varnish/default.vcl
	# change port in the varnish service file, line 9
	sed -i "s| :6081 | ${I}:80 |g" /lib/systemd/system/varnish.service

	# reload the systemd service, then varnish
	cmd systemctl daemon-reload
	cmd systemctl restart varnish apache2
	msg_info "Installation of Varnish completed!"
}	# end install_varnish
