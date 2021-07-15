# ------------------------------------------------------------------------------
# install apache2 2.4.38 web server for debian 10 buster
# https://reposcope.com/package/apache2
# ------------------------------------------------------------------------------

install_apache2() {
	# abort if apache2 is already installed
	Pkg.installed "apache2-bin" && {
		Msg.warn "apache2 is already installed..."
		return
	}
	# abort also if nginx is installed
	Pkg.installed "nginx" && {
		Msg.warn "Found nginx! Installation of apache2 cannot continue"
		return
	}

	# install required packages
	Msg.info "Installing apache2 for ${ENV_os}..."
	Pkg.install apache2 apache2-utils apache2-suexec-pristine ssl-cert

	Msg.info "Configuring apache2..."

	# enable apache2 modules
	a2enmod suexec rewrite ssl actions include cgi headers

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
	Firewall.allow 'http'

	Msg.info "Configuration of apache2 completed!"
}	# end install_apache2




