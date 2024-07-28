# ------------------------------------------------------------------------------
# install dovecot 2.3.13 for debian 11 bullseye
# ------------------------------------------------------------------------------

Install.dovecot() {
	Pkg.installed "dovecot-imapd" && {
		Msg.warn "Dovecot is already installed..."
		return
	}

	Msg.info "Installing Dovecot for ${ENV_os}..."

	# install required & useful packages
	Pkg.install dovecot-imapd dovecot-pop3d dovecot-mysql dovecot-sieve dovecot-lmtpd

	# activating ports on firewall
	Fw.allow 'imap imaps pop3 pop3s'

	Msg.info "Installation of Dovecot completed!"
}	# end Install.dovecot
