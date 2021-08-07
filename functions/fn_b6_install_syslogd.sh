# ------------------------------------------------------------------------------
# simple vanilla syslogd to replace rsyslogd
# which allocates ~30MB privvmpages on an OpenVZ system
# ------------------------------------------------------------------------------

Install.syslogd() {
	# install syslogd to replace rsyslogd
	# no arguments expected
	Pkg.installed "inetutils-syslogd" || {
		Msg.info "Installing inetutils-syslogd..."
		Pkg.purge "rsyslogd"
		Pkg.install inetutils-syslogd logrotate
	}

	Msg.info "Configuring inetutils-syslogd..."

	# there is no need to log to so many files
	local e p=/var/log
	for e in $p/*.log $p/mail.* $p/debug $p/syslog $p/fsck $p/news
		do rm -rf "$e"
	done

	# dash before path means to not flush immediately at every logged line
	cat > /etc/syslog.conf <<- EOF
		*.*;auth,authpriv,cron,kern,mail.none	-/var/log/syslog
		auth,authpriv.*							-/var/log/auth.log
		cron.*									-/var/log/cron.log
		kern.=!warning							-/var/log/kern.log
		kern.=warning							-/var/log/iptables.log
		mail.err								-/var/log/mail.err
		mail.*									-/var/log/mail.log
		EOF

	# install /etc/logrotate.d/inetutils-syslogd
	p='/etc/logrotate.d'
	mkdir -p "$p"
	rm -f "$p/inetutils-syslogd"
	File.into "$p" inetutils-syslogd

	> /var/log/syslog
	cmd systemctl restart inetutils-syslogd
	cmd logrotate -f /etc/logrotate.conf > /dev/null 2>&1
	Msg.info "Configuration of inetutils-syslogd completed!"
}	# end Install.syslogd
