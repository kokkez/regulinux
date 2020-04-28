# ------------------------------------------------------------------------------
# install nextcloud 18 for debian 9 with php 7.3
# ------------------------------------------------------------------------------

install_nextcloud18() {
	local URL VER="18.0.0"	# v18 for php 7

	msg_info "Installing Nextcloud ${VER}..."

	# install some php libraries before install Nextcloud
	pkg_install php7.3-{cli,curl,gd,imap,intl,mbstring,xml,xmlrpc,zip} \
		php-{apcu,imagick,memcache} imagemagick memcached bzip2 mcrypt
		# php7.3-mcrypt there is no more

	# new database with related user, info saved in ~/.dbdata.txt
	create_database "nextcloud" "nextcloud"

	# copy script to facilitate with permissions
	copy_to ~/ nextcloud/nextcloud-*

	# download & install nextcloud
	cd /var/www
	URL="https://download.nextcloud.com/server/releases/nextcloud-${VER}.zip"
	down_load "${URL}" "nextcloud.zip"
	unzip -qo nextcloud.zip
	rm -rf nextcloud.zip
	chown -R 33:0 /var/www/nextcloud # set user www-data
	mkdir -p /var/www/nextcloud-data && chown -R 33:0 "$_" # set data folder too as www-data

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
	msg_info "Installation of nextcloud ${VER} completed!"
}	# end install_nextcloud18
