# ------------------------------------------------------------------------------
# install a self-signed certificate
# ------------------------------------------------------------------------------

sslcert_symlinks() {
	# create the symlink pointing to a real file
	# $1 - file name to convert to symlink
	# $2 - path to the real file
	is_symlink ${1} || {
		mv -f ${1} ${1}.bak
		ln -s ${2} ${1}
	}
}	# end sslcert_symlinks


sslcert_paths() {
	# adjust paths to points to these certificates
	# $1 - path to the key file
	# $2 - path to the certificate file

	# adjust default-ssl symlink for apache
	[ -s /etc/apache2/sites-available/default-ssl.conf ] && {
		cd /etc/apache2/sites-enabled
		is_symlink '0000-default-ssl.conf' || {
			ln -s ../sites-available/default-ssl.conf '0000-default-ssl.conf'
			rm -rf default-ssl*
		}
		# enable related modules, then restart apache2
		a2enmod rewrite headers ssl
		svc_evoke apache2 restart
	}

	# default certificates path
	[ -s /etc/ssl/certs/ssl-cert-snakeoil.pem ] && {
		cd /etc/ssl/private
		sslcert_symlinks 'ssl-cert-snakeoil.key' ${1}
		cd /etc/ssl/certs
		sslcert_symlinks 'ssl-cert-snakeoil.pem' ${2}
	}

	# postfix paths
	[ -s /etc/postfix/smtpd.cert ] && {
		cd /etc/postfix
		sslcert_symlinks 'smtpd.key' ${1}
		sslcert_symlinks 'smtpd.cert' ${2}
	}

	# ispconfig paths
	[ -s /usr/local/ispconfig/interface/ssl/ispserver.crt ] && {
		cd /usr/local/ispconfig/interface/ssl
		sslcert_symlinks 'ispserver.key' ${1}
		sslcert_symlinks 'ispserver.crt' ${2}
	}
}	# end sslcert_paths


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

	sslcert_paths "${D}.key" "${D}.cert"
	msg_info "Generation of self-signed SSL Certificate completed!"
}	# end install_selfsigned_sslcert
