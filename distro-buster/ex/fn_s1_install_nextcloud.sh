# ------------------------------------------------------------------------------
# install nextcloud for debian 9 with php 7.0
# ------------------------------------------------------------------------------

install_nextcloud() {
	local u v="15.0.14"	# latest for php 7.0

	Msg.info "Installing Nextcloud ${v}..."

	# install some php libraries before install Nextcloud
	Pkg.install php-{cli,gd,zip,curl,intl,imap,xmlrpc,xml,mbstring,apcu} \
		php-imagick imagemagick memcached php-memcache bzip2 php-mcrypt mcrypt

	# new database with related user, info saved in ~/.dbdata.txt
	create_database "nextcloud" "nextcloud"

	# copy script to facilitate with permissions
	File.into ~/ nextcloud/nextcloud-*

	# download & install nextcloud
	cd /var/www
	u="https://download.nextcloud.com/server/releases/nextcloud-${v}.zip"
	File.download "$u" "nextcloud.zip"
	unzip -qo nextcloud.zip
	rm -rf nextcloud.zip
	mkdir -p /var/www/nextcloud-data # custom data folder
	chown -R 33:0 /var/www/nextcloud* # set user www-data

	# apache configuration
	cd /etc/apache2
	File.into sites-available nextcloud/nextcloud13.conf
	[ -L sites-enabled/110-nextcloud.conf ] || {
		ln -s ../sites-available/nextcloud13.conf sites-enabled/110-nextcloud.conf
	}
	cmd a2enmod rewrite headers env dir mime ssl
	cmd a2ensite default-ssl
	cmd systemctl restart apache2

	# cron configuration
	[ -s /etc/crontab ] && grep -q NEXTCLOUD /etc/crontab || {
		File.backup /etc/crontab
		cat <<EOF >> /etc/crontab

# NEXTCLOUD scheduled cleaning
*/15 * * * * www-data php -f /var/www/nextcloud/cron.php
EOF
	}
	Msg.info "Installation of nextcloud $v completed!"
}	# end install_nextcloud
