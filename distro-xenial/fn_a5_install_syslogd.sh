# ------------------------------------------------------------------------------
# simple vanilla syslogd to replace rsyslogd
# which allocates ~30MB privvmpages on an OpenVZ system
# ------------------------------------------------------------------------------

install_syslogd() {
	is_installed "inetutils-syslogd" || {
		msg_info "Installing inetutils-syslogd..."
		pkg_purge "rsyslogd"
		pkg_install inetutils-syslogd logrotate
	}

	msg_info "Configuring inetutils-syslogd..."

	# there is no need to log to so many files
	cd /var/log
	local F
	for F in *.log mail.* debug syslog fsck news
		do rm -rf ${F}
	done

	# dash before path means to not flush immediately at every logged line
	cat <<EOF > /etc/syslog.conf
*.*;auth,authpriv,cron,kern,mail.none	-/var/log/syslog
auth,authpriv.*							-/var/log/auth.log
cron.*									-/var/log/cron.log
kern.=!warning							-/var/log/kern.log
kern.=warning							-/var/log/iptables.log
mail.err								-/var/log/mail.err
mail.*									-/var/log/mail.log
EOF

	# install /etc/logrotate.d/inetutils-syslogd from MyDir
	mkdir -p /etc/logrotate.d && cd "$_"
	rm -f inetutils-syslogd
	copy_to . inetutils-syslogd

	> /var/log/syslog
	svc_evoke inetutils-syslogd restart
	cmd logrotate -f /etc/logrotate.conf > /dev/null 2>&1
	msg_info "Configuration of inetutils-syslogd completed!"
}	# end install_syslogd
