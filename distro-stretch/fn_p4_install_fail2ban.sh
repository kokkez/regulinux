# ------------------------------------------------------------------------------
# install fail2ban 0.9.6 for debian 9 stretch
# https://reposcope.com/package/fail2ban
# ------------------------------------------------------------------------------

install_fail2ban() {
	# abort if fail2ban is already installed
	is_installed "fail2ban" && {
		Msg.warn "fail2ban is already installed..."
		return
	}

	Msg.info "Installing fail2ban..."
	pkg_install fail2ban

	Msg.info "Configuring fail2ban..."

	# make fail2ban do some monitoring
	cd /etc/fail2ban
	copy_to . fail2ban/jail.local
	sed -i "s|HOST_NICK|${HOST_NICK}|" jail.local

	# creating filter files
	cd filter.d
	[ -r pureftpd.conf ] || {
		copy_to . fail2ban/pureftpd.conf
	}
	[ -r dovecot-pop3imap.conf ] || {
		copy_to . fail2ban/dovecot-pop3imap.conf
	}
	# add the missing "ignoreregex" line in postfix-sasl filter
	[ -r postfix-sasl.conf ] && {
		grep -q "ignoreregex" postfix-sasl.conf || {
			echo "ignoreregex =" >> postfix-sasl.conf
		}
	}

	cmd systemctl restart fail2ban
	Msg.info "Installation of Fail2ban completed!"
}	# end install_fail2ban
