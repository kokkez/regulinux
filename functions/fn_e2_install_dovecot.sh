# ------------------------------------------------------------------------------
# install dovecot
# ------------------------------------------------------------------------------

Install.dovecot() {
	Pkg.installed "dovecot-imapd" && {
		Msg.warn "Dovecot is already installed..."
		return
	}

	Msg.info "Installing Dovecot for ${ENV_os}..."

	# preseed dovecot on jessie
	[ "$ENV_release" = "debian-8" ] && {
		debconf-set-selections <<-EOF
			dovecot-core dovecot-core/create-ssl-cert boolean true
			dovecot-core dovecot-core/ssl-cert-name string $HOST_FQDN
			EOF
	}

	# install required & useful packages
	Pkg.install dovecot-imapd dovecot-pop3d dovecot-mysql dovecot-sieve dovecot-lmtpd

	# activating ports on firewall
	Fw.allow 'mail'

	Msg.info "Installation of dovecot completed!"
}	# end Install.dovecot
