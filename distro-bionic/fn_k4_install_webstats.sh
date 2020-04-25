# ------------------------------------------------------------------------------
# install some web statistics packages
# ------------------------------------------------------------------------------

install_webstats() {
	# install some web statistics packages
	is_installed "vlogger" || {
		msg_info "Installing Web statistics packages..."

		pkg_install vlogger webalizer awstats geoip-database libclass-dbi-mysql-perl

		sed -i 's/^/#/;s/^##/#/g' /etc/cron.d/awstats

		msg_info "Installation of web statistics packages completed!"
	}
}	# end install_webstats
