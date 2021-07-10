# ------------------------------------------------------------------------------
# install web server
# ------------------------------------------------------------------------------

install_pureftpd() {
	is_installed "pure-ftpd-mysql" || {
		Msg.info "Installing PureFTPd..."
		pkg_install pure-ftpd-common pure-ftpd-mysql
	}

	Msg.info "Configuring PureFTPd..."

	# setting up Pure-Ftpd
	sed -ri 's|(VIRTUALCHROOT=)false|\1true|' /etc/default/pure-ftpd-common
	echo "40010 40910" > /etc/pure-ftpd/conf/PassivePortRange
	echo 1 > /etc/pure-ftpd/conf/TLS

	# creating the certificate
	local DIRE=/etc/ssl/private
	mkdir -p ${DIRE}
	[ -r "${DIRE}/pure-ftpd.pem" ] || {
		openssl req -x509 -nodes -days 7300 -newkey rsa:2048 \
			-keyout "${DIRE}/pure-ftpd.pem" -out "${DIRE}/pure-ftpd.pem" \
			-subj "/C=${CERT_C}/ST=${CERT_ST}/L=${CERT_L}/O=${CERT_O}/OU=${CERT_OU}/CN=${CERT_CN}/emailAddress=${CERT_E}"
		chmod 600 pure-ftpd.pem
	}

	# activating ports on firewall
	firewall_allow "ftp"

	svc_evoke pure-ftpd-mysql restart
	Msg.info "Installation of PureFTPd completed!"
}	# end install_pureftpd
