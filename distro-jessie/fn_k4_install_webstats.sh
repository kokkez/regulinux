# ------------------------------------------------------------------------------
# install some web statistics packages
# ------------------------------------------------------------------------------

install_webstats() {
	# install some web statistics packages
	Pkg.installed "vlogger" || {
		Msg.info "Installing Web statistics packages..."

		pkg_install vlogger webalizer awstats geoip-database libclass-dbi-mysql-perl

		sed -i 's/^/#/;s/^##/#/g' /etc/cron.d/awstats

		Msg.info "Installation of web statistics packages completed!"
	}
}	# end install_webstats
