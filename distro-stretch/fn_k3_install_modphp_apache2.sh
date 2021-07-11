# ------------------------------------------------------------------------------
# install MOD-PHP for apache2 (default 7.0) for debian 9 stretch
# ------------------------------------------------------------------------------

install_modphp_apache2() {
	# abort if package is already installed
	Pkg.installed "libapache2-mod-php" && {
		Msg.warn "PHP as MOD-PHP for apache2 is already installed..."
		return
	}

	# now install php packages
	pkg_install php libapache2-mod-php php-mysql php-gd

	# adjust date.timezone in all php.ini
	sed -ri "s|^;(date\.timezone =).*|\1 '${TIME_ZONE}'|" /etc/php/*/*/php.ini

	Msg.info "Installation of PHP as MOD-PHP for apache2 completed!"
}	# end install_modphp_apache2




