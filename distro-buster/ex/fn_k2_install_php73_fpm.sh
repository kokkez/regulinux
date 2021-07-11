# ------------------------------------------------------------------------------
# install PHP 7.3 as MOD-PHP and PHP-FPM
# ------------------------------------------------------------------------------

install_php73_fpm() {
	# abort if package was already installed
	Pkg.installed "libapache2-mod-fcgid" && {
		Msg.warn "PHP as PHP-FPM is already installed..."
		return
	}

	# add external repository for updated php
	Pkg.installed "apt-transport-https" || {
		Msg.info "Installing required packages..."
		Pkg.install apt-transport-https lsb-release ca-certificates
	}
	down_load https://packages.sury.org/php/apt.gpg /etc/apt/trusted.gpg.d/php.gpg
	cat <<EOF > /etc/apt/sources.list.d/php.list
# https://www.patreon.com/oerdnj
deb http://packages.sury.org/php stretch main
#deb-src http://packages.sury.org/php stretch main
EOF

	# forcing apt update
	Pkg.update 'coerce'

	# now install php 7.3 packages and some modules
	Pkg.install libapache2-mod-fcgid php7.3 libapache2-mod-php7.3 \
		php7.3-cli php7.3-cgi php7.3-fpm php7.3-mysql php7.3-gd php7.3-bcmath \
		php7.3-curl php7.3-imap php7.3-intl php7.3-mbstring \
		php7.3-pspell php7.3-recode php7.3-soap php7.3-sqlite3 php7.3-tidy \
		php7.3-xmlrpc php7.3-xsl php7.3-zip \
		php-apcu php-apcu-bc php-gettext php-imagick imagemagick \
		php-memcache php-memcached memcached mcrypt php-pear
#		php-redis

	# enable apache2 modules
	a2enmod proxy_fcgi fcgid setenvif alias

	Msg.info "Configuring PHP as PHP-FPM for apache2..."
	cd /etc/apache2

	# setting up the default DirectoryIndex
	[ -r mods-available/dir.conf ] && {
		sed -ri 's|^(\s*DirectoryIndex).*|\1 index.php index.html|' mods-available/dir.conf
	}

	# adjust date.timezone in all php.ini
	sed -ri "s|^;(date\.timezone =).*|\1 '${TIME_ZONE}'|" /etc/php/*/*/php.ini

	# cgi.fix_pathinfo provides *real* PATH_INFO/PATH_TRANSLATED support for CGI
	sed -ri 's|^;(cgi.fix_pathinfo).*|\1 = 1|' /etc/php/*/fpm/php.ini

	# set alternative for php in manual (cli) mode
	cmd update-alternatives --set php /usr/bin/php7.3

	# instruct apache2 on the default version to use
	cmd a2dismod php7.0 php7.1 php7.2 php7.4
	cmd a2enmod php7.3

	cmd systemctl restart apache2
	Msg.info "Installation of PHP as PHP-FPM completed!"
}	# end install_php73_fpm
