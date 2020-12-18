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

	msg_info "Configuring nginx..."

	# shut off server_tokens
	local F=/etc/nginx/nginx.conf
	[ -r "${F}" ] && {
		sed -ri ${F} \
			-e 's|# server_tokens off;|server_tokens off;|'
	}

	# rename "default" in sites-enabled, if valid symlink
	cd /etc/nginx/sites-enabled
	[ -L "default" ] && mv "default" "0000-default"

	# activating ports on firewall
	firewall_allow "http"

	msg_info "Configuration of nginx completed!"
}	# end install_nginx




