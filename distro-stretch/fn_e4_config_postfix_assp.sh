# ------------------------------------------------------------------------------
# postfix configuration for assp
# ------------------------------------------------------------------------------

config_postfix_assp() {
	# set main.cf for use with assp
	cd /etc/postfix
	[ -r main.cf ] || {
		msg_error "Missing main.cf, skipping configuration"
	}

	# install opendkim
	is_installed "opendkim" || {
		pkg_install opendkim opendkim-tools
	}

	msg_info "Configuring postfix..."
	backup_file main.cf

	# set some parameters in main.cf
	cmd postconf \
		myhostname=${MAIL_NAME} \
		myorigin=${HOST_FQDN} \
		mydestination= \
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
	copy_to . postfix/mysql-*

	# set master.cf to listen on 127.0.0.1:1025
	[ -r master.cf ] && {
		backup_file master.cf
		sed -i 's|^smtp      inet|1025      inet|' master.cf
	}

	svc_evoke postfix restart
	msg_info "Configuration of postfix completed!"
}	# end config_postfix_assp
