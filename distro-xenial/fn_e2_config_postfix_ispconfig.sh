# ------------------------------------------------------------------------------
# postfix configuration for ispconfig
# ------------------------------------------------------------------------------

config_postfix_ispconfig() {
	# set master.cf to listen on ports 465 & 587
	cd /etc/postfix
	[ -r master.cf ] || {
		Msg.warn "Missing master.cf, skipping configuration"
		return
	}

	# install getmail4
	pkg_require getmail4

	Msg.info "Configuring Postfix..."

	# uncommenting some lines in master.cf file
	backup_file master.cf
	sed -ri master.cf \
		-e 's|#(submission)|\1|' \
		-e 's|#(  -o syslog)|\1|' \
		-e 's|#(  -o smtpd_tl)|\1|' \
		-e '/#  -o smtpd_sa/a\  -o smtpd_client_restrictions=permit_sasl_authenticated,reject' \
		-e 's|#(  -o smtpd_sa)|\1|' \
		-e 's|#(smtps)|\1|'

	svc_evoke postfix restart
	Msg.info "Configuration of postfix completed!"
}	# end config_postfix_ispconfig
