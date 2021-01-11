# ------------------------------------------------------------------------------
# install some web statistics packages
# ------------------------------------------------------------------------------

install_webstats() {
	# abort if web statistics packages are already installed
	is_installed "vlogger" && {
		msg_alert "Web statistics packages are already installed..."
		return
	}

	# install some web statistics packages
	msg_info "Installing Web statistics packages..."
	pkg_install vlogger webalizer awstats geoip-database libclass-dbi-mysql-perl

	# stop awstats cronjobs
	sed -i 's/^/#/;s/^##/#/g' /etc/cron.d/awstats

	msg_info "Installation of web statistics packages completed!"
}	# end install_webstats
