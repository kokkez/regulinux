# ------------------------------------------------------------------------------
# install some web statistics packages
# ------------------------------------------------------------------------------

install_webstats() {
	# abort if web statistics packages are already installed
	Pkg.installed "vlogger" && {
		Msg.warn "Web statistics packages are already installed..."
		return
	}

	# install some web statistics packages
	Msg.info "Installing Web statistics packages..."
	Pkg.install vlogger webalizer awstats geoip-database libclass-dbi-mysql-perl

	# stop awstats cronjobs
	sed -i 's/^/#/;s/^##/#/g' /etc/cron.d/awstats

	Msg.info "Installation of web statistics packages completed!"
}	# end install_webstats
