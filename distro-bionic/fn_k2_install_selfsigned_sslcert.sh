# ------------------------------------------------------------------------------
# install a self-signed certificate
# ------------------------------------------------------------------------------

install_selfsigned_sslcert() {
	# create a self-signed certificate
	local D=/etc/ssl/myserver
	mkdir -p "${D}"		# create the parent directory
	D="${D}/server"		# certificate path prefix

	# check that was not already generated
	[ -r "${D}.cert" ] && {
		msg_alert "SSL Certificate ( ${D}.cert ) is already generated..."
		return
	}

	msg_info "Generating self-signed SSL Certificate..."

	# now write the certificate
	openssl rand -out ~/.rnd -hex 256
	openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
		-keyout "${D}.key" -out "${D}.cert" \
		-subj "/C=${CERT_C}/ST=${CERT_ST}/L=${CERT_L}/O=${CERT_O}/OU=${CERT_OU}/CN=${CERT_CN}/emailAddress=${CERT_E}"
#	chmod 600 "${D}.key"

	# create symlinks for apache
	[ -s /etc/apache2/sites-available/default-ssl.conf ] && {
		cd /etc/ssl/certs
		is_symlink 'ssl-cert-snakeoil.pem' || {
			mv -f ssl-cert-snakeoil.pem ssl-cert-snakeoil.pem.bak
			ln -s ${D}.cert ssl-cert-snakeoil.pem
		}
		cd /etc/ssl/private
		is_symlink 'ssl-cert-snakeoil.key' || {
			mv -f ssl-cert-snakeoil.key ssl-cert-snakeoil.key.bak
			ln -s ${D}.key ssl-cert-snakeoil.key
		}
		# adjust default-ssl symlink
		cd /etc/apache2
		is_symlink sites-enabled/0000-default-ssl.conf || {
			ln -s ../sites-available/default-ssl.conf sites-enabled/0000-default-ssl.conf
			rm -rf sites-enabled/default-ssl*
		}
		# enable related modules, then restart apache2
		a2enmod rewrite headers ssl
		svc_evoke apache2 restart
	}

	msg_info "Generation of self-signed SSL Certificate completed!"
}	# end install_selfsigned_sslcert
