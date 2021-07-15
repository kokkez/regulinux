# ------------------------------------------------------------------------------
# install apache2 web server with php5
# ------------------------------------------------------------------------------

install_apache2() {
	local p="php5"

	# install Apache 2.4, FCGI, suExec & others...
	Pkg.installed "apache2-mpm-prefork" || {
		Msg.info "Installing apache2 for ${ENV_os}..."
		Pkg.install apache2 apache2-mpm-prefork apache2-suexec \
			libapache2-mod-fcgid libapache2-mod-python libexpat1 ssl-cert
		# apache2-doc libapache2-mod-passenger libruby
	}

	# install PHP5, pear, mcrypt, xcache & others...
	Pkg.installed "libapache2-mod-php5" || {
		Msg.info "Installing ${p}..."
		Pkg.install libapache2-mod-php5 php5 php5-common php5-cgi php5-cli \
			php5-curl php5-mysqlnd php5-imap php5-ldap php5-intl \
			php5-gd php5-imagick imagemagick php5-mcrypt mcrypt \
			php5-pspell php5-recode php5-sqlite php5-tidy tidy \
			php5-xmlrpc php5-xsl php5-xcache snmp php-pear php-auth
	}

	# enable required apache2 modules
	Msg.info "Activating apache2 modules..."
	a2enmod suexec rewrite ssl actions include alias fcgid
	# plus dav_fs, dav, and auth_digest if you want to use WebDAV
#	a2enmod dav_fs dav auth_digest

	Msg.info "Configuring apache2 with ${p}..."

	# comment out the line application/x-ruby rb in /etc/mime.types
	sed -ri /etc/mime.types -e 's|^(application/x-ruby)|#\1|'

	cd /etc/apache2

	# setting up the default DirectoryIndex
	[ -r mods-available/dir.conf ] && {
		sed -ri mods-available/dir.conf \
			-e 's|^(\s*DirectoryIndex).*|\1 index.php index.html|'
	}

	# shut off ServerTokens and ServerSignature
	[ -r conf.d/security.conf ] && {
		sed -ri conf.d/security.conf \
			-e 's|^(ServerTokens) OS|\1 Prod|' \
			-e 's|^(ServerSignature) On|\1 Off|'
	}

	# edit deprecated comments in some php ini files
	[ -r /etc/php5/conf.d/ming.ini ] && {
		sed -i /etc/php5/conf.d/ming.ini -e 's|^#|;|'
	}

	# adjust expose_php & date.timezone in all php.ini
	sed -ri /etc/php5/*/php.ini \
		-e "s|^(expose_php =) On|\1 Off|" \
		-e "s|^;(date\.timezone =).*|\1 '$TIME_ZONE'|"

	# activating ports on firewall
	Firewall.allow 'http'

	svc_evoke apache2 restart
	Msg.info "Installation of apache2 with $p completed!"
}	# end install_apache2
