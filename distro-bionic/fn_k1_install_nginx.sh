# ------------------------------------------------------------------------------
# install nginx web server (version 1.14.0 on bionic)
# ------------------------------------------------------------------------------

install_nginx() {
	# abort if package was already installed
	is_installed "nginx" && {
		msg_alert "nginx is already installed..."
		return
	}

	# install required packages
	msg_info "Installing nginx..."
	pkg_install nginx ssl-cert

	msg_info "Configuring apache2..."

	# shut off ServerTokens and ServerSignature
#	[ -r conf-available/security.conf ] && {
#		sed -ri conf-available/security.conf \
#			-e 's|^(ServerTokens).*|\1 Prod|' \
#			-e 's|^(ServerSignature).*|\1 Off|'
#	}

	# activating ports on firewall
	firewall_allow "http"

	msg_info "Configuration of nginx completed!"
}	# end install_nginx




