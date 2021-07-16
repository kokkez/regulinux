# ------------------------------------------------------------------------------
# install some web statistics packages
# ------------------------------------------------------------------------------

Install.webstats() {
	# abort if web statistics packages are already installed
	Pkg.installed "vlogger" && {
		Msg.warn "Web statistics packages are already installed..."
		return
	}

	# install some web statistics packages
	Msg.info "Installing Web statistics packages..."
	Pkg.install vlogger webalizer awstats geoip-database libclass-dbi-mysql-perl

	# stop awstats cronjobs
	sed -i /etc/cron.d/awstats -e 's/^/#/;s/^##/#/g'

	Msg.info "Installation of web statistics packages completed!"
}	# end Install.webstats
