# ------------------------------------------------------------------------------
# install a self-signed certificate
# ------------------------------------------------------------------------------

sslcert_symlink() {
	# create the symlink pointing to a real file
	# $1 - path to the file to convert to symlink
	# $2 - path to the target file
	File.islink "$1" || {
		[ -s "$1" ] && {
			mv -f "$1" "${1}.bak"
			[ "${2:0:1}" = "/" ] || cd $(cmd dirname "$1")
			[ -s "$2" ] && ln -nfs "$2" "$1"
		}
	}
}	# end sslcert_symlink


sslcert_paths() {
	# adjust paths to points to these certificates
	# $1 - full path to the key file
	# $2 - full path to the certificate file
	Arg.expect "$1" "$2" || return

	# default certificate paths
	sslcert_symlink '/etc/ssl/private/ssl-cert-snakeoil.key' "$1"
	sslcert_symlink '/etc/ssl/certs/ssl-cert-snakeoil.pem' "$2"

	# postfix certificate paths
	sslcert_symlink '/etc/postfix/smtpd.key' "$1"
	sslcert_symlink '/etc/postfix/smtpd.cert' "$2"

	# ispconfig certificate paths
	sslcert_symlink '/usr/local/ispconfig/interface/ssl/ispserver.key' "$1"
	sslcert_symlink '/usr/local/ispconfig/interface/ssl/ispserver.crt' "$2"

	# adjust default-ssl symlink for apache
	[ -s /etc/apache2/sites-available/default-ssl.conf ] && {
		cd /etc/apache2/sites-enabled
		File.islink '0000-default-ssl.conf' || {
			ln -s ../sites-available/default-ssl.conf '0000-default-ssl.conf'
			rm -rf default-ssl*
		}
		# enable related modules, then restart apache2
		a2enmod rewrite headers ssl
		cmd systemctl restart apache2
	}

	# restart nginx webserver if installed
	[ "$HTTP_SERVER" = "nginx" ] && cmd systemctl restart nginx

	Msg.info "Symlinks for the given SSL Certificate completed!"
}	# end sslcert_paths


install_sslcert_selfsigned() {
	# create a self-signed certificate
	local d=/etc/ssl/myserver
	mkdir -p "$d"		# create the parent directory
	d="$d/server"		# certificate path prefix

	# abort if certificate is already generated
	[ -r "${d}.cert" ] && {
		Msg.warn "SSL Certificate ( ${d}.cert ) is already generated..."
		return
	}

	Msg.info "Generating self-signed SSL Certificate..."

	# write the certificate
	openssl rand -out ~/.rnd -hex 256
	openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
		-keyout "${d}.key" -out "${d}.cert" \
		-subj "/C=${CERT_C}/ST=${CERT_ST}/L=${CERT_L}/O=${CERT_O}/OU=${CERT_OU}/CN=${CERT_CN}/emailAddress=${CERT_E}"
#	chmod 600 "${d}.key"

	# symlink the certificate paths
	sslcert_paths "${d}.key" "${d}.cert"

	Msg.info "Generation of self-signed SSL Certificate completed!"
}	# end install_sslcert_selfsigned
