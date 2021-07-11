# ------------------------------------------------------------------------------
# install PHP as MOD-PHP, PHP-FPM and FastCGI
# ------------------------------------------------------------------------------

install_php_fpm() {
	# abort if package was already installed
	Pkg.installed "libapache2-mod-fcgid" && {
		Msg.warn "PHP as PHP-FPM is already installed..."
		return
	}

	# add external repository for updated php
#	Pkg.installed "software-properties-common" || {
#		Msg.info "Installing required packages..."
#		pkg_install python-software-properties software-properties-common
#	}
#	LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
	# append external repository for updated php
	cd /etc/apt
	grep -q 'Ondrej Sury' sources.list || {
		apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C
#		Pkg.update 'coerce'
		cat >> sources.list <<EOF

# Ondrej Sury Repo for PHP 7.x
deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main
# deb-src http://ppa.launchpad.net/ondrej/php/ubuntu xenial main
EOF
	}

	# forcing apt update
	Pkg.update 'coerce'

	# now install php packages, 2 versions, 7.0 and 7.3, and some modules
	pkg_install libapache2-mod-fcgid \
		php7.3 libapache2-mod-php7.3 \
		php7.3-cgi php7.3-mysql php7.3-curl php7.3-intl php7.3-zip \
		php7.3-mbstring php7.3-sqlite3 php7.3-imap php7.3-gd php7.3-pspell \
		php7.3-recode php7.3-soap php7.3-tidy php7.3-xmlrpc php7.3-xsl \
		php-pear mcrypt php-apcu php-apcu-bc php-gettext php-imagick imagemagick

#		libapache2-mod-php7.0 \
#		php7.0 php7.0-cli php7.0-cgi php7.0-fpm php7.0-mysql php7.0-gd \
#		php7.0-curl php7.0-imap php7.0-intl php7.0-mbstring php7.0-mcrypt \
#		php7.0-pspell php7.0-recode php7.0-soap php7.0-sqlite3 php7.0-tidy \
#		php7.0-xmlrpc php7.0-xsl php7.0-zip \

#		libapache2-mod-php7.3 \
#		php7.3 php7.3-cli php7.3-cgi php7.3-fpm php7.3-mysql php7.3-gd \
#		php7.3-curl php7.3-imap php7.3-intl php7.3-mbstring \
#		php7.3-pspell php7.3-recode php7.3-soap php7.3-sqlite3 php7.3-tidy \
#		php7.3-xmlrpc php7.3-xsl php7.3-zip \

	# enable apache2 modules
#	a2enmod proxy_fcgi setenvif fastcgi alias
	a2enmod proxy_fcgi fcgid setenvif alias

	Msg.info "Configuring PHP for apache2..."
	cd /etc/apache2

	# setting up the default DirectoryIndex
	[ -r mods-available/dir.conf ] && {
		sed -ri 's|^(\s*DirectoryIndex).*|\1 index.php index.html|' mods-available/dir.conf
	}

	# adjust date.timezone in all php.ini
	sed -ri "s|^;(date\.timezone =).*|\1 '${TIME_ZONE}'|" /etc/php/*/*/php.ini

	# cgi.fix_pathinfo provides *real* PATH_INFO/PATH_TRANSLATED support for CGI
	sed -ri 's|^;(cgi.fix_pathinfo).*|\1 = 1|' /etc/php/*/fpm/php.ini

	# set oldest alternative for php in manual mode
#	cmd update-alternatives --set php /usr/bin/php7.3
#	cmd update-alternatives --set php-cgi /usr/bin/php-cgi7.3

	# instruct apache2 on the default version to use
#	cmd a2dismod php7.0
#	cmd a2enmod php7.3

	svc_evoke apache2 restart
	Msg.info "Installation of PHP as PHP-FPM completed!"
}	# end install_php_fpm
