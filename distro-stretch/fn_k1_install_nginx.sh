# ------------------------------------------------------------------------------
# install nginx 1.10.3 web server for debian 9 stretch
# https://reposcope.com/package/nginx
# ------------------------------------------------------------------------------

install_nginx() {
	# abort if nginx is already installed
	Pkg.installed "nginx" && {
		Msg.warn "nginx is already installed..."
		return
	}
	# abort also if apache2 is installed
	Pkg.installed "apache2-bin" && {
		Msg.warn "Found apache2! Installation of nginx cannot continue"
		return
	}

	# install required packages
	Msg.info "Installing nginx for ${ENV_os}..."
	Pkg.install nginx ssl-cert

	Msg.info "Configuring nginx..."

	# shut off server_tokens
	local f=/etc/nginx/nginx.conf
	[ -s "$f" ] && {
		sed -i $f \
			-e 's|# server_names_|server_names_|' \
			-e 's|# server_tokens|server_tokens|'
	}

	# add a generic includer to "default" in sites-available
	f=/etc/nginx/sites-available/default
	grep -q '\-nginx.conf' $f || {
		sed -ri $f -e 's|^}|\n\tinclude snippets/*-nginx.conf;\n}|'
	}
	# enabling SSL
	sed -i $f \
		-e 's|# listen |listen |g' \
		-e 's|# include |include |'

	# rename "default" in sites-enabled, if valid symlink
	cd /etc/nginx/sites-enabled
	File.islink "default" && mv "default" "0000-default"

	# activating ports on firewall
	Fw.allow 'http'

	Msg.info "Configuration of nginx completed!"
}	# end install_nginx




