# ------------------------------------------------------------------------------
# install PHP-FPM for nginx (default 7.3 + other version) for debian 10 buster
# https://dev.to/pushkaranand/upgrading-to-php-7-4-26dg
# ------------------------------------------------------------------------------

install_phpfpm_nginx() {
	local v=7.4

	# abort if package was already installed
	Pkg.installed "php${v}-fpm" && {
		Msg.warn "PHP$v as PHP-FPM is already installed..."
		return
	}

	# add external repository for updated php
	Repo.php

	# install the default php 7.3, + some versions, with modules
	Pkg.install php7.3 \
		php7.3-{apcu,apcu-bc,bcmath,bz2,cgi,cli,curl,fpm,gd,gmp,imap,intl,ldap,mbstring,mysql,pspell,recode,soap,sqlite3,tidy,xmlrpc,xsl,zip} \
		php${v} \
		php${v}-{apcu,apcu-bc,bcmath,bz2,cgi,cli,curl,fpm,gd,gmp,imap,intl,ldap,mbstring,mysql,pspell,soap,sqlite3,tidy,xmlrpc,xsl,zip} \
		php-{gettext,imagick,pear} imagemagick bzip2 mcrypt
#		php7.4-{cgi,cli,curl,fpm,gd,imap,intl,mbstring,mysql,pspell,recode,soap,sqlite3,tidy,xmlrpc,xsl,zip} \
#		php-{memcache,memcached} memcached \

	# explicitly set php in cli mode
	cmd update-alternatives --set php /usr/bin/php${v}
#	cmd update-alternatives --auto php

	Msg.info "Configuring PHP for nginx..."
	cd /etc/nginx

	# adjust date.timezone in all php.ini
	sed -ri /etc/php/*/*/php.ini -e "s|^;(date\.timezone =).*|\1 '$TIME_ZONE'|"

	# cgi.fix_pathinfo provides *real* PATH_INFO/PATH_TRANSLATED support for CGI
	sed -ri /etc/php/*/fpm/php.ini -e 's|^;(cgi.fix_pathinfo).*|\1 = 0|'

	cmd systemctl restart nginx
	Msg.info "Installation of PHP$v as PHP-FPM completed!"
}	# end install_phpfpm_nginx
