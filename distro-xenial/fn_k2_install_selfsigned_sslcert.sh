# ------------------------------------------------------------------------------
# install a self-signed certificate
# ------------------------------------------------------------------------------

install_selfsigned_sslcert() {
	# create a self-signed certificate
	local d=/etc/ssl/myserver
	mkdir -p "$d"		# conditional creating the parent directory
	d="$d/server"		# certificate path prefix

	# check that was not already generated
	[ -r "${d}.cert" ] && {
		Msg.warn "SSL Certificate ( ${d}.cert ) is already generated..."
		return
	}

	Msg.info "Generating self-signed SSL Certificate..."

	# now write the certificate
	openssl rand -out ~/.rnd -hex 256
	openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
		-keyout "${d}.key" -out "${d}.cert" \
		-subj "/C=${CERT_C}/ST=${CERT_ST}/L=${CERT_L}/O=${CERT_O}/OU=${CERT_OU}/CN=${CERT_CN}/emailAddress=${CERT_E}"
#	chmod 600 "${d}.key"

	# edit default-ssl.conf
	cd /etc/apache2/sites-available
	#	SSLCertificateFile		/etc/ssl/myserver/server.cert
	#	SSLCertificateKeyFile	/etc/ssl/myserver/server.key
	[ -s default-ssl.conf ] && {
		sed -ri default-ssl.conf \
			-e "s|^(\s*SSLCertificateFile).*|\1 ${d}.cert|" \
			-e "s|^(\s*SSLCertificateKeyFile).*|\1 ${d}.key|"

		# enable related apache2 modules & site, then restart it
		a2enmod rewrite headers ssl
		a2ensite default-ssl
		svc_evoke apache2 restart
	}

	Msg.info "Generation of self-signed SSL Certificate completed!"
}	# end install_selfsigned_sslcert
