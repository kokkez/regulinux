# ------------------------------------------------------------------------------
# install apache2 web server (version 2.4.25 on stretch)
# ------------------------------------------------------------------------------

install_apache2() {
	# abort if package was already installed
	is_installed "apache2-bin" && {
		msg_alert "apache2 is already installed..."
		return
	}

	# install required packages
	msg_info "Installing apache2..."
	pkg_install apache2 apache2-utils apache2-suexec-pristine ssl-cert

	msg_info "Configuring apache2..."

	# enable apache2 modules
	a2enmod suexec rewrite ssl actions include headers

	cd /etc/apache2

	# ensure that the server can not be attacked trough the HTTPOXY
	# vulnerability, disabling the HTTP_PROXY header in apache globally
	cat > conf-available/httpoxy.conf <<EOF
<IfModule mod_headers.c>
	RequestHeader unset Proxy early
</IfModule>
EOF
	a2enconf httpoxy

	# shut off ServerTokens and ServerSignature
	[ -r conf-available/security.conf ] && {
		sed -ri conf-available/security.conf \
			-e 's|^(ServerTokens).*|\1 Prod|' \
			-e 's|^(ServerSignature).*|\1 Off|'
	}

	# activating ports on firewall
	firewall_allow "http"

	msg_info "Configuration of apache2 completed!"
}	# end install_apache2




