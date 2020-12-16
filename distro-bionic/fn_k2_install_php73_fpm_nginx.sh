# ------------------------------------------------------------------------------
# install PHP 7.3 as PHP-FPM for nginx
# https://dev.to/pushkaranand/upgrading-to-php-7-4-26dg
# ------------------------------------------------------------------------------

install_php73_fpm_nginx() {
	local V=7.3

	# abort if package was already installed
	is_installed "libapache2-mod-fcgid" && {
		msg_alert "PHP${V} as MOD-PHP is already installed..."
		return
	}

	# add external repository for updated php
	add_php_repository

	# now install php packages, versions 7.4, with some modules
	pkg_install php${V} \
		php${V}-{apcu,apcu-bc,bcmath,bz2,cgi,cli,curl,fpm,gd,gmp,imap,intl,ldap,mbstring,mysql,pspell,soap,sqlite3,tidy,xmlrpc,xsl,zip} \
		php-{gettext,imagick,pear} imagemagick bzip2 mcrypt
#		php7.3-{cgi,cli,curl,fpm,gd,imap,intl,mbstring,mysql,pspell,recode,soap,sqlite3,tidy,xmlrpc,xsl,zip} \
#		php-{memcache,memcached} memcached \

	# set alternative for php in cli mode
	cmd update-alternatives --set php /usr/bin/php${V}

	msg_info "Configuring PHP for nginx..."
	cd /etc/nginx

	# setting up the default DirectoryIndex
	[ -r mods-available/dir.conf ] && {
#		sed -ri 's|^(\s*DirectoryIndex).*|\1 index.php index.html|' mods-available/dir.conf
	}

	# adjust date.timezone in all php.ini
	sed -ri "s|^;(date\.timezone =).*|\1 '${TIME_ZONE}'|" /etc/php/*/*/php.ini

	# cgi.fix_pathinfo provides *real* PATH_INFO/PATH_TRANSLATED support for CGI
	sed -ri 's|^;(cgi.fix_pathinfo).*|\1 = 1|' /etc/php/*/fpm/php.ini

	svc_evoke nginx restart
	msg_info "Installation of PHP${V} as MOD-PHP completed!"
}	# end install_php73_fpm_nginx
