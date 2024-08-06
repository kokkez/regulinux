# ------------------------------------------------------------------------------
# install a self-signed certificate
# ------------------------------------------------------------------------------

install_selfsigned_sslcert() {
	# create a self-signed certificate
	local c s=/etc/ssl/myserver
	mkdir -p "$s"		# conditional creating the parent directory
	s="$s/server"		# certificate path prefix

	# check that was not already installed
	[ -r "${s}.cert" ] && {
		Msg.warn "SSL Certificate ( ${s}.cert ) is already installed..."
		return
	}

	Msg.info "Installing self-signed SSL Certificate..."

	# now write the certificate
	openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
		-keyout "${s}.key" -out "${s}.cert" \
		-subj "/C=${CERT_C}/ST=${CERT_ST}/L=${CERT_L}/O=${CERT_O}/OU=${CERT_OU}/CN=${CERT_CN}/emailAddress=${CERT_E}"
#	chmod 600 "${s}.key"

	# edit /etc/apache2/sites-available/default-ssl
	c=/etc/apache2/sites-available/default-ssl
	#	SSLCertificateFile		/etc/ssl/myserver/server.cert
	#	SSLCertificateKeyFile	/etc/ssl/myserver/server.key
	[ -s "$c" ] && {
		sed -ri $c \
			-e "s|^(\s*SSLCertificateFile).*|\1 ${s}.cert|" \
			-e "s|^(\s*SSLCertificateKeyFile).*|\1 ${s}.key|"

		# enable related apache2 modules & site, then restart it
		a2enmod rewrite headers ssl
		a2ensite default-ssl
		svc_evoke apache2 restart
	}

	Msg.info "Installation of self-signed SSL Certificate completed!"
}	# end install_selfsigned_sslcert
