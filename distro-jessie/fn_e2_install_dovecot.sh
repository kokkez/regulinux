# ------------------------------------------------------------------------------
# install dovecot
# ------------------------------------------------------------------------------

install_dovecot() {
	is_installed "dovecot-imapd" && {
		msg_alert "Dovecot is already installed..."
		return
	}

	msg_info "Installing Dovecot..."

	# preseed dovecot
	debconf-set-selections <<EOF
dovecot-core dovecot-core/create-ssl-cert boolean true
dovecot-core dovecot-core/ssl-cert-name string ${HOST_FQDN}
EOF

	# install required & useful packages
	pkg_install dovecot-imapd dovecot-pop3d dovecot-mysql dovecot-sieve dovecot-lmtpd

	# activating ports on firewall
	firewall_allow "mail"

	msg_info "Installation of dovecot completed!"
}	# end install_dovecot
