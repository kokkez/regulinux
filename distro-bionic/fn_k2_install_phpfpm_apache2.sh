# ------------------------------------------------------------------------------
# install MOD-PHP, PHP-FPM, FastCGI for apache2 (default 7.2 + other version)
# for ubuntu 18.04 bionic
# https://dev.to/pushkaranand/upgrading-to-php-7-4-26dg
# ------------------------------------------------------------------------------

install_phpfpm_apache2() {
	local v=7.4

	# abort if apache2 is already installed
	Pkg.installed "libapache2-mod-fcgid" && {
		Msg.warn "PHP$v as MOD-PHP, PHP-FPM and FastCGI is already installed..."
		return
	}

	# add external repository for updated php
	add_php_repository

	# install php packages with some modules
	Pkg.install libapache2-mod-fcgid \
		php7.2 libapache2-mod-php7.2 \
		php7.2-{apcu,apcu-bc,bcmath,bz2,cgi,cli,curl,fpm,gd,gmp,imap,intl,ldap,mbstring,mysql,pspell,recode,soap,sqlite3,tidy,xmlrpc,xsl,zip} \
		php${v} libapache2-mod-php${v} \
		php${v}-{apcu,apcu-bc,bcmath,bz2,cgi,cli,curl,fpm,gd,gmp,imap,intl,ldap,mbstring,mysql,pspell,soap,sqlite3,tidy,xmlrpc,xsl,zip} \
		php-{gettext,imagick,pear} imagemagick bzip2 mcrypt

	Msg.info "Configuring PHP for apache2..."
	cd /etc/apache2

	# enable apache2 modules
	a2enmod proxy_fcgi setenvif fastcgi alias

	# set alternative for php in cli mode (update-alternatives --display php)
	cmd update-alternatives --auto php
#	cmd update-alternatives --set php /usr/bin/php${v}

	# set default php to newest version
	a2dismod php*
	a2enmod php$v

	# setting up the default DirectoryIndex
	[ -r mods-available/dir.conf ] && {
		sed -ri 's|^(\s*DirectoryIndex).*|\1 index.php index.html|' mods-available/dir.conf
	}

	# adjust date.timezone in all php.ini
	sed -ri "s|^;(date\.timezone =).*|\1 '${TIME_ZONE}'|" /etc/php/*/*/php.ini

	# cgi.fix_pathinfo provides *real* PATH_INFO/PATH_TRANSLATED support for CGI
	sed -ri 's|^;(cgi.fix_pathinfo).*|\1 = 1|' /etc/php/*/fpm/php.ini

	cmd systemctl restart apache2
	Msg.info "Installation of PHP$v as MOD-PHP, PHP-FPM and FastCGI completed!"
}	# end install_phpfpm_apache2
