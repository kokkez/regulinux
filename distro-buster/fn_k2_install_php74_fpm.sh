# ------------------------------------------------------------------------------
# install PHP 7.4 as MOD-PHP and PHP-FPM
# https://dev.to/pushkaranand/upgrading-to-php-7-4-26dg
# ------------------------------------------------------------------------------

install_php74_fpm() {
	# abort if package was already installed
	is_installed "libapache2-mod-fcgid" && {
		msg_alert "PHP as PHP-FPM is already installed..."
		return
	}

	# add external repository for updated php
	is_installed "apt-transport-https" || {
		msg_info "Installing required packages..."
		pkg_install apt-transport-https lsb-release ca-certificates
	}
	down_load https://packages.sury.org/php/apt.gpg /etc/apt/trusted.gpg.d/php.gpg
	cat <<EOF > /etc/apt/sources.list.d/php.list
# https://www.patreon.com/oerdnj
deb http://packages.sury.org/php stretch main
#deb-src http://packages.sury.org/php stretch main
EOF

	# forcing apt update
	pkg_update true

	# now install php 7.4 packages and some modules
	pkg_install libapache2-mod-fcgid \
		php7.4 libapache2-mod-php7.4 \
		php7.4-cli php7.4-cgi php7.4-fpm php7.4-mysql php7.4-gd php7.4-bcmath \
		php7.4-bz2 php7.4-curl php7.4-imap php7.4-intl php7.4-ldap \
		php7.4-mbstring php7.4-pspell php7.4-soap php7.4-sqlite3 \
		php7.4-tidy php7.4-xmlrpc php7.4-xsl php7.4-zip php-pear mcrypt \
		php-apcu php-apcu-bc php-gettext php-imagick imagemagick
#		php7.4-recode php-memcache php-memcached memcached

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
	msg_info "Installation of PHP as PHP-FPM completed!"
}	# end install_php74_fpm
