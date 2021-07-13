# ------------------------------------------------------------------------------
# install fail2ban 0.9.6 for debian 9 stretch
# https://reposcope.com/package/fail2ban
# ------------------------------------------------------------------------------

install_fail2ban() {
	# abort if fail2ban is already installed
	Pkg.installed "fail2ban" && {
		Msg.warn "fail2ban is already installed..."
		return
	}

	Msg.info "Installing fail2ban for ${ENV_os}..."
	Pkg.install fail2ban

	Msg.info "Configuring fail2ban..."

	# make fail2ban do some monitoring
	local p="/etc/fail2ban"
	File.into $p fail2ban/jail.local
	sed -i $p/jail.local -e "s|HOST_NICK|$HOST_NICK|"

	# creating filter files
	p+="/filter.d"
	[ -r $p/pureftpd.conf ] || {
		File.into $p fail2ban/pureftpd.conf
	}
	[ -r $p/dovecot-pop3imap.conf ] || {
		File.into $p fail2ban/dovecot-pop3imap.conf
	}
	# add the missing "ignoreregex" line in postfix-sasl filter
	[ -r $p/postfix-sasl.conf ] && {
		grep -q "ignoreregex" $p/postfix-sasl.conf || {
			echo "ignoreregex =" >> $p/postfix-sasl.conf
		}
	}

	cmd systemctl restart fail2ban
	Msg.info "Installation of Fail2ban completed!"
}	# end install_fail2ban
