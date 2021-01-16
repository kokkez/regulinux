# ------------------------------------------------------------------------------
# install ftp server PureFTPd 1.0.46 for ubuntu 18.04 bionic
# ------------------------------------------------------------------------------

install_pureftpd() {
	# abort if PureFTPd is already installed
	is_installed "pure-ftpd-mysql" && {
		msg_alert "PureFTPd is already installed..."
		return
	}

	msg_info "Installing PureFTPd..."
	pkg_install pure-ftpd-common pure-ftpd-mysql

	msg_info "Configuring PureFTPd..."

	# setting up Pure-Ftpd
	sed -ri 's|(VIRTUALCHROOT=)false|\1true|' /etc/default/pure-ftpd-common
	echo "40010 40910" > /etc/pure-ftpd/conf/PassivePortRange
	echo 1 > /etc/pure-ftpd/conf/TLS

	# creating the certificate
	local D=/etc/ssl/private
	mkdir -p ${D}
	[ -r "${D}/pure-ftpd.pem" ] || {
		openssl req -x509 -nodes -days 7300 -newkey rsa:2048 \
			-keyout "${D}/pure-ftpd.pem" -out "${D}/pure-ftpd.pem" \
			-subj "/C=${CERT_C}/ST=${CERT_ST}/L=${CERT_L}/O=${CERT_O}/OU=${CERT_OU}/CN=${CERT_CN}/emailAddress=${CERT_E}"
		chmod 600 pure-ftpd.pem
	}

	# activating ports on firewall
	firewall_allow "ftp"

	cmd systemctl restart pure-ftpd-mysql
	msg_info "Installation of PureFTPd completed!"
}	# end install_pureftpd