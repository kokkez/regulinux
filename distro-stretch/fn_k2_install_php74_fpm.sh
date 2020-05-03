# ------------------------------------------------------------------------------
# install PHP 7.4 as MOD-PHP, PHP-FPM and FastCGI
# https://dev.to/pushkaranand/upgrading-to-php-7-4-26dg
# ------------------------------------------------------------------------------

install_php74_fpm() {
	local V=7.4

	# abort if package was already installed
	is_installed "libapache2-mod-fcgid" && {
		msg_alert "PHP${V} as MOD-PHP, PHP-FPM and FastCGI is already installed..."
		return
	}

	# add external repository for updated php
	add_php_repository

	# now install php packages, versions 7.4, with some modules
	pkg_install libapache2-mod-fcgid \
		php${V} libapache2-mod-php${V} \
		php${V}-{bcmath,bz2,cgi,cli,curl,fpm,gd,imap,intl,ldap,mbstring,mysql,pspell,soap,sqlite3,tidy,xmlrpc,xsl,zip} \
		php-{apcu,apcu-bc,gettext,imagick,memcache,memcached,pear} imagemagick memcached mcrypt
#		php7.3-{cgi,cli,curl,fpm,gd,imap,intl,mbstring,mysql,pspell,recode,soap,sqlite3,tidy,xmlrpc,xsl,zip} \

	# enable apache2 modules
	a2enmod proxy_fcgi fcgid setenvif alias

	msg_info "Configuring PHP as PHP-FPM for apache2..."
	cd /etc/apache2

	# setting up the default DirectoryIndex
	[ -r mods-available/dir.conf ] && {
		sed -ri 's|^(\s*DirectoryIndex).*|\1 index.php index.html|' mods-available/dir.conf
	}

	# adjust date.timezone in all php.ini
	sed -ri "s|^;(date\.timezone =).*|\1 '${TIME_ZONE}'|" /etc/php/*/*/php.ini

	# cgi.fix_pathinfo provides *real* PATH_INFO/PATH_TRANSLATED support for CGI
	sed -ri 's|^;(cgi.fix_pathinfo).*|\1 = 1|' /etc/php/*/fpm/php.ini

	svc_evoke apache2 restart
	msg_info "Installation of PHP${V} as MOD-PHP, PHP-FPM and FastCGI completed!"
}	# end install_php74_fpm
