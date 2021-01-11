# ------------------------------------------------------------------------------
# install MOD-PHP, PHP-FPM, FastCGI for apache2 (default 7.0 + other version)
# for debian 9 stretch
# https://dev.to/pushkaranand/upgrading-to-php-7-4-26dg
# ------------------------------------------------------------------------------

install_phpfpm_apache2() {
	local V=7.4

	# abort if packages are already installed
	is_installed "libapache2-mod-fcgid" && {
		msg_alert "PHP${V} as MOD-PHP, PHP-FPM and FastCGI is already installed..."
		return
	}

	# add external repository for updated php
	add_php_repository

	# install php packages with some modules
	pkg_install libapache2-mod-fcgid \
		php7.0 libapache2-mod-php7.0 \
		php7.0-{bcmath,bz2,cgi,cli,curl,fpm,gd,gmp,imap,intl,ldap,mbstring,mcrypt,mysql,pspell,recode,soap,sqlite3,tidy,xmlrpc,xsl,zip} \
		php${V} libapache2-mod-php${V} \
		php${V}-{apcu,apcu-bc,bcmath,bz2,cgi,cli,curl,fpm,gd,gmp,imap,intl,ldap,mbstring,mysql,pspell,soap,sqlite3,tidy,xmlrpc,xsl,zip} \
		php5.6 libapache2-mod-php5.6 \
		php5.6-{bcmath,cgi,cli,curl,fpm,gd,gmp,imap,intl,mbstring,mcrypt,mysql,pspell,recode,soap,sqlite3,tidy,xmlrpc,xsl,zip} \
		php-{gettext,imagick,pear} imagemagick bzip2 mcrypt

	msg_info "Configuring PHP as PHP-FPM for apache2..."
	cd /etc/apache2

	# enable apache2 modules
	a2enmod proxy_fcgi fcgid setenvif alias

	# set alternative for php in cli mode (update-alternatives --display php)
	cmd update-alternatives --auto php
#	cmd update-alternatives --set php /usr/bin/php${V}

	# set default php to newest version
	a2dismod php*
	a2enmod php${V}

	# setting up the default DirectoryIndex
	[ -r mods-available/dir.conf ] && {
		sed -ri 's|^(\s*DirectoryIndex).*|\1 index.php index.html|' mods-available/dir.conf
	}

	# adjust date.timezone in all php.ini
	sed -ri "s|^;(date\.timezone =).*|\1 '${TIME_ZONE}'|" /etc/php/*/*/php.ini

	# cgi.fix_pathinfo provides *real* PATH_INFO/PATH_TRANSLATED support for CGI
	sed -ri 's|^;(cgi.fix_pathinfo).*|\1 = 1|' /etc/php/*/fpm/php.ini

	cmd systemctl restart apache2
	msg_info "Installation of PHP${V} as MOD-PHP, PHP-FPM and FastCGI completed!"
}	# end install_phpfpm_apache2
