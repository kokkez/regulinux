# ------------------------------------------------------------------------------
# install nextcloud 19 for ubuntu 18 with php 7.x >= 7.2
# ------------------------------------------------------------------------------

install_nextcloud() {
	local P U V="19.0.4"	# version to install

	# test that php version is at least 7.2
	P="$(php_version minor)"
	dpkg --compare-versions "${P}" "lt" "7.2" && {
		msg_alert "Nextcloud ${V} require PHP7.2 but PHP${P} is installed..."
		return
	}

	msg_info "Installing Nextcloud ${V}..."

	# install some php libraries before install Nextcloud
	add_php_repository
	pkg_install php${P}-{bcmath,cli,curl,gd,gmp,imap,intl,mbstring,xml,xmlrpc,zip} \
		php-{apcu,imagick,pear,redis} imagemagick bzip2 mcrypt redis-server

	# new database with related user, info saved in ~/.dbdata.txt
	[ -d /var/lib/mysql/nextcloud ] || create_database "nextcloud" "nextcloud"

	# copy script to facilitate with permissions
	copy_to ~/ nextcloud/nextcloud-*

	# download & install nextcloud
	cd /var/www
	U="https://download.nextcloud.com/server/releases/nextcloud-${V}.zip"
	down_load "${U}" "nextcloud.zip"
	unzip -qo nextcloud.zip
	rm -rf nextcloud.zip
	chown -R 33:0 /var/www/nextcloud # set user www-data
	mkdir -p /var/www/nextcloud-data && chown -R 33:0 "$_" # set data folder too as www-data

	# apache configuration
	cd /etc/apache2
	copy_to sites-available nextcloud/nextcloud.conf
	cd /sites-enabled
	[ -L 110-nextcloud.conf ] || ln -s ../sites-available/nextcloud.conf 110-nextcloud.conf
	[ -L 000-default.conf ] && mv 000-default.conf 0000-default.conf
	[ -L default-ssl.conf ] && mv default-ssl.conf 0000-default-ssl.conf
	cmd a2enmod rewrite headers env dir mime ssl
	cmd a2ensite default-ssl
	svc_evoke apache2 restart

	# cron configuration
	[ -s /etc/crontab ] && grep -q NEXTCLOUD /etc/crontab || {
		backup_file /etc/crontab
		cat >> /etc/crontab <<EOF

# NEXTCLOUD scheduled cleaning
*/15 * * * * www-data php -f /var/www/nextcloud/cron.php
EOF
	}

	# aliasize the occ command
	grep -q 'alias occ' ~/.bashrc || {
		cat >> ~/.bashrc <<EOF

# alias occ for nextcloud
occ() { su -s /bin/bash www-data -c "/usr/bin/php /var/www/nextcloud/occ $@"; }
EOF
	}

	msg_info "Installation of nextcloud ${V} completed!"
}	# end install_nextcloud
