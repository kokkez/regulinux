# ------------------------------------------------------------------------------
# postfix configuration for Cyrus sasl2
# ------------------------------------------------------------------------------

config_postfix_sasl2_sql() {
	# sources:
	# https://wiki.debian.org/PostfixAndSASL
	# postfix.state-of-mind.de/patrick.koetter/smtpauth/sasldb_configuration.html
	Pkg.installed "libsasl2-modules-sql" && {
		Msg.warn "Cyrus sasl2 is already installed"
		return
	}
	Msg.info "Installing Cyrus-SASL ..."

	# install software
	Pkg.install postfix libsasl2-modules libsasl2-modules-sql sasl2-bin

	# creating smtpd.conf
	local c=/etc/postfix/sasl/smtpd.conf
	[ -s "$c" ] || File.place postfix/smtpd.conf "$c"

	# edit postfix configuration
	cmd postconf \
		smtpd_tls_security_level=may \
		smtpd_sasl_security_options=noanonymous \
		smtpd_sasl_local_domain=servermx \
		smtpd_sasl_auth_enable=yes \
		broken_sasl_auth_clients=yes

	# restart postfix, because reloading is not enough
	svc_evoke postfix restart
	Msg.info "Installation of Cyrus-SASL completed!"
}	# end config_postfix_sasl2_sql
