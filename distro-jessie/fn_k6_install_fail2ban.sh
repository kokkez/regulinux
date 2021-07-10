# ------------------------------------------------------------------------------
# install fail2ban
# ------------------------------------------------------------------------------

install_fail2ban() {
	is_installed "fail2ban" || {
		Msg.info "Installing fail2ban..."
		pkg_install fail2ban
	}

	Msg.info "Configuring fail2ban..."

	# make fail2ban do some monitoring
	cd /etc/fail2ban
	copy_to . fail2ban/jail.local
	sed -i "s|SSHD_PORT|${SSHD_PORT}|" jail.local

	# creating filter files
	cd filter.d
	[ -r pureftpd.conf ] || copy_to . fail2ban/pureftpd.conf
	[ -r dovecot-pop3imap.conf ] || copy_to . fail2ban/dovecot-pop3imap.conf
	# add the missing "ignoreregex" line in postfix-sasl filter
	[ -r postfix-sasl.conf ] && {
		grep -q "ignoreregex" postfix-sasl.conf || {
			echo "ignoreregex =" >> postfix-sasl.conf
		}
	}

	svc_evoke fail2ban restart
	Msg.info "Installation of Fail2ban completed!"
}	# end install_fail2ban
