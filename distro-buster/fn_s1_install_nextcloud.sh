# ------------------------------------------------------------------------------
# install nextcloud 19 (php min 7.2) debian 10 buster
# ------------------------------------------------------------------------------

install_nextcloud() {
	local p u v="19.0.6"	# version to install

	# test that php version is at least 7.2
	p="$( Version.php minor )"
	dpkg --compare-versions "$p" "lt" "7.2" && {
		Msg.warn "Nextcloud $v require PHP7.2 but PHP$p is installed..."
		return
	}

	Msg.info "Installing Nextcloud ${v}..."

	# install some php libraries before install Nextcloud
	add_php_repository
	Pkg.install php${p}-{apcu,apcu-bc,bcmath,cli,curl,gd,gmp,imap,intl,mbstring,xml,xmlrpc,zip} \
		php-{imagick,pear,redis} imagemagick bzip2 mcrypt redis-server

	# new database with related user, info saved in ~/.dbdata.txt
	[ -d /var/lib/mysql/nextcloud ] || create_database "nextcloud" "nextcloud"

	# copy script to facilitate with permissions
	File.into ~/ nextcloud/nextcloud-*-perm.sh

	# download & install nextcloud
	cd /var/www
	u="https://download.nextcloud.com/server/releases/nextcloud-${v}.zip"
	File.download "$u" "nextcloud.zip"
	unzip -qo nextcloud.zip
	rm -rf nextcloud.zip
	chown -R 33:0 /var/www/nextcloud # set user www-data
	mkdir -p /var/www/nextcloud-data && chown -R 33:0 "$_" # set data folder too as www-data

	# aliasize the occ command
	grep -q 'alias occ' ~/.bashrc || {
		cat >> ~/.bashrc <<EOF

# alias occ for nextcloud
occ() { su -s /bin/bash www-data -c "/usr/bin/php /var/www/nextcloud/occ \${*}"; }
EOF
	}

	# cron configuration
	[ -s /etc/crontab ] && grep -q '# NEXTCLOUD' /etc/crontab || {
		File.backup /etc/crontab
		cat >> /etc/crontab <<EOF

# NEXTCLOUD scheduled cleaning
*/15 * * * * www-data php -f /var/www/nextcloud/cron.php
EOF
	}

	# webserver configuration
	if [ "$HTTP_SERVER" = "nginx" ]; then
		File.into /etc/nginx/snippets nextcloud/nextcloud-nginx.conf
		# configure environment variables for php-fpm
		sed -ri /etc/php/*/fpm/pool.d/www.conf -e 's|^;env\[|env\[|'
		cmd systemctl restart nginx
	else
		cd /etc/apache2/sites-enabled
		File.into ../sites-available/ nextcloud/nextcloud.conf
		[ -L 110-nextcloud.conf ] || ln -nfs ../sites-available/nextcloud.conf 110-nextcloud.conf
		[ -L 000-default.conf ] && mv 000-default.conf 0000-default.conf
		[ -L default-ssl.conf ] && mv default-ssl.conf 0000-default-ssl.conf
		cmd a2enmod rewrite headers env dir mime ssl
		cmd a2ensite default-ssl
		cmd systemctl restart apache2
	fi;

	Msg.info "Installation of nextcloud $v completed!"
}	# end install_nextcloud
