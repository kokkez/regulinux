# ------------------------------------------------------------------------------
# install PHP 5.6 & 7.4 as MOD-PHP, PHP-FPM and FastCGI
# https://dev.to/pushkaranand/upgrading-to-php-7-4-26dg
# ------------------------------------------------------------------------------

install_php7x_fpm() {
	# abort if package was already installed
	is_installed "libapache2-mod-fcgid" && {
		msg_alert "PHP as MOD-PHP, PHP-FPM and FastCGI is already installed..."
		return
	}

	# append external repository for updated php
	cd /etc/apt
	grep -q 'Ondrej Sury' sources.list || {
		pkg_require gnupg
		apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C
		cat >> sources.list <<EOF

# Ondrej Sury Repo for PHP 7.x [ https://www.patreon.com/oerdnj ]
deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main
# deb-src http://ppa.launchpad.net/ondrej/php/ubuntu xenial main
EOF
	}

	# forcing apt update
	pkg_update true

	# now install php packages, versions 5.6 & 7.4, with some modules
	pkg_install libapache2-mod-fcgid \
		php5.6 libapache2-mod-php5.6 \
		php5.6-{cgi,cli,curl,fpm,gd,imap,intl,mbstring,mcrypt,mysql,pspell,recode,soap,sqlite3,tidy,xmlrpc,xsl,zip} \
		php7.4 libapache2-mod-php7.4 \
		php7.4-{bcmath,bz2,cgi,cli,curl,fpm,gd,imap,intl,ldap,mbstring,mysql,pspell,soap,sqlite3,tidy,xmlrpc,xsl,zip} \
		php-{apcu,apcu-bc,gettext,imagick,memcache,memcached,pear} imagemagick memcached mcrypt
#		php7.3-{cgi,cli,curl,fpm,gd,imap,intl,mbstring,mysql,pspell,recode,soap,sqlite3,tidy,xmlrpc,xsl,zip} \

	# enable apache2 modules
	a2enmod proxy_fcgi setenvif fastcgi alias

	# set alternative for php in cli mode
	cmd update-alternatives --set php /usr/bin/php7.4

	# set default php to v7.x
	a2dismod php5.6
	a2enmod php7.4

	msg_info "Configuring PHP for apache2..."
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
	msg_info "Installation of PHP as MOD-PHP, PHP-FPM and FastCGI completed!"
}	# end install_php7x_fpm
