# ------------------------------------------------------------------------------
# install some web statistics packages
# ------------------------------------------------------------------------------

install_webstats() {
	# install some web statistics packages
	Pkg.installed "vlogger" || {
		Msg.info "Installing Web statistics packages..."

		Pkg.install vlogger webalizer awstats geoip-database libclass-dbi-mysql-perl

		sed -i /etc/cron.d/awstats -e 's/^/#/;s/^##/#/g'

		Msg.info "Installation of web statistics packages completed!"
	}
}	# end install_webstats
