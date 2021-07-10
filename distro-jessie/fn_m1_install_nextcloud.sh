# ------------------------------------------------------------------------------
# install nextcloud for debian 8 with php 5.6
# ------------------------------------------------------------------------------

install_nextcloud() {
	local URL VER="13.0.12"	# v13 for php 5.6 or 7

	Msg.info "Installing Nextcloud ${VER}..."

	# install some php libraries before install Nextcloud
	pkg_install php5-{cli,curl,gd,imagick,imap,intl,ldap,mcrypt,memcached,xmlrpc} \
		php-{apc,pclzip} memcached bzip2

	# new database with related user, info saved in ~/.dbdata.txt
	create_database "nextcloud" "nextcloud"

	# copy script to facilitate with permissions
	copy_to ~/ nextcloud/nextcloud-*

	# go, install Nextcloud
	cd /var/www
	URL="https://download.nextcloud.com/server/releases/nextcloud-${VER}.zip"
	down_load "${URL}" "nextcloud.zip"
	unzip -qo nextcloud.zip
	rm -rf nextcloud.zip
	mkdir -p /var/www/nextcloud-data # custom data folder
	chown -R 33:0 /var/www/nextcloud* # set user www-data

	# apache configuration
	cd /etc/apache2
	copy_to sites-available nextcloud/nextcloud13.conf
	[ -L sites-enabled/110-nextcloud.conf ] || {
		ln -s ../sites-available/nextcloud13.conf sites-enabled/110-nextcloud.conf
	}
	cmd a2enmod rewrite headers env dir mime ssl
	cmd a2ensite default-ssl
	svc_evoke apache2 restart

	# cron configuration
	[ -s /etc/crontab ] && grep -q NEXTCLOUD /etc/crontab || {
		backup_file /etc/crontab
		cat <<EOF >> /etc/crontab

# NEXTCLOUD scheduled cleaning
*/15 * * * * www-data php -f /var/www/nextcloud/cron.php
EOF
	}
	Msg.info "Installation of nextcloud ${VER} completed!"
}	# end install_nextcloud
