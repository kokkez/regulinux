# ------------------------------------------------------------------------------
# postfix configuration for assp
# ------------------------------------------------------------------------------

config_postfix_assp() {
	# set main.cf for use with assp
	cd /etc/postfix
	[ -r main.cf ] || {
		Msg.error "Missing main.cf, skipping configuration"
	}

	# install opendkim
	Pkg.installed "opendkim" || {
		Pkg.install opendkim opendkim-tools
	}

	Msg.info "Configuring postfix..."
	File.backup main.cf

	# set basic parameters in main.cf
	cmd postconf \
		myhostname=${MAIL_NAME} \
		myorigin=\$myhostname \
		mydestination=\$myorigin,localhost \
		mynetworks=127.0.0.1 \
		inet_interfaces=all \
		message_size_limit=51200000 \
		bounce_queue_lifetime=30m \
		maximal_queue_lifetime=30m
#		inet_interfaces=loopback-only \
#		inet_protocols=ipv4 \
#		"#disable_vrfy_command=yes"

	# TLS parameters for client
	cmd postconf \
		smtp_tls_security_level=may \
		smtp_sasl_security_options=noanonymous \
		smtp_sasl_tls_security_options=noanonymous \
		smtp_sasl_auth_enable=yes \
		smtp_always_send_ehlo=yes \
		smtp_sasl_password_maps=mysql:/etc/postfix/mysql-credentials \
		smtp_sasl_mechanism_filter=plain,login
#		smtp_use_tls=yes \
#		"#smtp_tls_loglevel=1"

	# relay domains & transports
	cmd postconf \
		virtual_alias_maps=proxy:mysql:/etc/postfix/mysql-aliasaddresses,proxy:mysql:/etc/postfix/mysql-aliasdomains \
		relay_domains=proxy:mysql:/etc/postfix/mysql-domains \
		relay_recipient_maps=proxy:mysql:/etc/postfix/mysql-recipients \
		transport_maps=proxy:mysql:/etc/postfix/mysql-transports \
		relayhost= \
		smtpd_recipient_restrictions=permit_mynetworks,permit_sasl_authenticated,reject_unauth_destination,reject_unverified_recipient \
		unverified_recipient_reject_code=550 \
		unverified_recipient_reject_reason='Address lookup failed' \
		address_verify_negative_refresh_time=1h

	# creating db config files
	File.into . postfix/mysql-*

	# set master.cf to listen on 127.0.0.1:1025
	[ -r master.cf ] && {
		File.backup master.cf
		sed -i master.cf -e 's|^smtp      inet|1025      inet|'
	}

	svc_evoke postfix restart
	Msg.info "Configuration of postfix completed!"
}	# end config_postfix_assp
