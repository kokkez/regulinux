# ------------------------------------------------------------------------------
# install a self-signed certificate
# ------------------------------------------------------------------------------

install_selfsigned_sslcert() {
	# create a self-signed certificate
	local D=/etc/ssl/myserver
	mkdir -p "${D}"		# conditional creating the parent directory
	D="${D}/server"		# certificate path prefix

	# check that was not already installed
	[ -r "${D}.cert" ] && {
		msg_alert "SSL Certificate ( ${D}.cert ) is already installed..."
		return
	}

	msg_info "Installing self-signed SSL Certificate..."

	# now write the certificate
	openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
		-keyout "${D}.key" -out "${D}.cert" \
		-subj "/C=${CERT_C}/ST=${CERT_ST}/L=${CERT_L}/O=${CERT_O}/OU=${CERT_OU}/CN=${CERT_CN}/emailAddress=${CERT_E}"
#	chmod 600 "${D}.key"

	# edit default-ssl.conf
	cd /etc/apache2/sites-available
	#	SSLCertificateFile		/etc/ssl/myserver/server.cert
	#	SSLCertificateKeyFile	/etc/ssl/myserver/server.key
	[ -s default-ssl.conf ] && {
		sed -ri default-ssl.conf \
			-e "s|^(\s*SSLCertificateFile).*|\1 ${D}.cert|" \
			-e "s|^(\s*SSLCertificateKeyFile).*|\1 ${D}.key|"

		# enable related apache2 modules & site, then restart it
		a2enmod rewrite headers ssl
		a2ensite default-ssl
		svc_evoke apache2 restart
	}

	msg_info "Installation of self-signed SSL Certificate completed!"
}	# end install_selfsigned_sslcert
