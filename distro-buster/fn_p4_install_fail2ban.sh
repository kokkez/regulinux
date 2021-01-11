# ------------------------------------------------------------------------------
# install fail2ban 0.10.2 for debian 10 buster
# ------------------------------------------------------------------------------

install_fail2ban() {
	# abort if fail2ban is already installed
	is_installed "fail2ban" && {
		msg_alert "fail2ban is already installed..."
		return
	}

	msg_info "Installing fail2ban..."
	pkg_install fail2ban

	msg_info "Configuring fail2ban..."

	# make fail2ban do some monitoring
	cd /etc/fail2ban
	copy_to . fail2ban/jail.local
	sed -i "s|HOST_NICK|${HOST_NICK}|" jail.local

	# creating filter files
	cd filter.d
	[ -r postfix-failedauth.conf ] || {
		copy_to . fail2ban/postfix-failedauth.conf
	}
	[ -r dovecot-pop3imap.conf ] || {
		copy_to . fail2ban/dovecot-pop3imap.conf
	}

	# fix a systemd bug found on xenial 16.04
	local X=/usr/lib/tmpfiles.d/fail2ban-tmpfiles.conf
	grep -q '/var' ${X} && {
		msg_info "Fixing a little systemd bug that prevent fail2ban to start"
		sed -i 's|/var||' ${X}
	}

	cmd systemctl restart fail2ban
	msg_info "Installation of Fail2ban completed!"
}	# end install_fail2ban
