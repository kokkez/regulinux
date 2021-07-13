# ------------------------------------------------------------------------------
# install varnish 5.2
# ------------------------------------------------------------------------------

install_varnish() {
	# abort if package was already installed
	Pkg.installed "varnish" && {
		Msg.warn "Varnish is already installed..."
		return
	}

	# check the presence of apache2
	Pkg.installed "apache2-bin" || {
		Msg.warn "apache2 is NOT installed..."
		return
	}

	Msg.info "Installing Varnish..."
	Pkg.install varnish

	Msg.info "Configuring Varnish..."

	# configuring apache2
	# replace port '80' with '8008' in configuration file "ports.conf"
	# and all virtual host files under the "sites-available" directory
	cd /etc/apache2
	sed -i ports.conf -e 's| 80$| 127.0.0.1:80|g'
#	sed -i sites-available/* -e 's|80>|8008>|g'

	# configuring apache2 for SSL
	# load all the necessary modules
	a2enmod ssl proxy proxy_balancer proxy_http
	cmd apachectl configtest
	local t p=sites-available/default-ssl.conf
	t="\t########################################################################
		# varnish global settings
		SetEnvIf			X-Forwarded-Proto https HTTPS=on

		ProxyPreserveHost	On
		ProxyRequests		Off
		ProxyPass			/	http://$HOST_NICK:80/
		ProxyPassReverse	/	http://$HOST_NICK:80/

		RequestHeader		set X-Forwarded-Port expr=%{SERVER_PORT}
		RequestHeader		set X-Forwarded-Proto expr=%{REQUEST_SCHEME}
		########################################################################"
	grep -q 'varnish' $p || {
		perl -i -pe "s|</VirtualHost>|$t\n\t</VirtualHost>|g" $p
	}

	# backup default varnish config file
	File.backup /etc/varnish/default.vcl
	# change port in 'backend default' section, line 18
	sed -i /etc/varnish/default.vcl -e 's|"8080"|"80"|g'
	# change port in the varnish service file, line 9
	sed -i /lib/systemd/system/varnish.service -e "s| :6081 | $HOST_NICK:80 |g"

	# reload the systemd service, then varnish
	cmd systemctl daemon-reload
	cmd systemctl restart varnish apache2
	Msg.info "Installation of Varnish completed!"
}	# end install_varnish
