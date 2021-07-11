# ------------------------------------------------------------------------------
# install fail2ban
# ------------------------------------------------------------------------------

install_fail2ban() {
	Pkg.installed "fail2ban" || {
		Msg.info "Installing fail2ban for ${ENV_os}..."
		pkg_install fail2ban
	}

	Msg.info "Configuring fail2ban..."

	# make fail2ban do some monitoring
	cd /etc/fail2ban
	File.into . fail2ban/jail.local
	sed -i "s|SSHD_PORT|${SSHD_PORT}|" jail.local

	# creating filter files
	cd filter.d
	[ -r pureftpd.conf ] || File.into . fail2ban/pureftpd.conf
	[ -r dovecot-pop3imap.conf ] || File.into . fail2ban/dovecot-pop3imap.conf
	# add the missing "ignoreregex" line in postfix-sasl filter
	[ -r postfix-sasl.conf ] && {
		grep -q "ignoreregex" postfix-sasl.conf || {
			echo "ignoreregex =" >> postfix-sasl.conf
		}
	}

	# fix a systemd bug of xenial 16.04
	local X=/usr/lib/tmpfiles.d/fail2ban-tmpfiles.conf
	grep -q '/var' ${X} && {
		Msg.info "Fixing a little systemd bug that prevent fail2ban to start"
		sed -i 's|/var||' ${X}
	}

	svc_evoke fail2ban restart
	Msg.info "Installation of Fail2ban completed!"
}	# end install_fail2ban
