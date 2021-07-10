# ------------------------------------------------------------------------------
# install PHP-FPM for usage with Apache
# ------------------------------------------------------------------------------

install_phpfpm() {
	pkg_require php5-fpm libapache2-mod-fastcgi

	cd /etc/php5/fpm

	# cgi.fix_pathinfo provides *real* PATH_INFO/PATH_TRANSLATED support for CGI
	[ -r php.ini ] && {
		File.backup php.ini
		sed -ri php.ini \
			-e 's|^(expose_php =) On|\1 Off|' \
			-e 's|^(upload_max_filesize).*|\1 = 32M|' \
			-e 's|^(post_max_size).*|\1 = 33M|' \
			-e 's|^;(cgi.fix_pathinfo).*|\1 = 1|'
	}

	# enable related apache2 modules, then restart php5-fpm
	a2enmod actions fastcgi alias
	svc_evoke php5-fpm restart

	Msg.info "Installation of php5-fpm completed!"
}	# end install_phpfpm
