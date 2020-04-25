# ------------------------------------------------------------------------------
# install nextcloud for debian 8 with php 5.6
# ------------------------------------------------------------------------------

menu_nextcloud() {
	[ -r /var/www/nextcloud/config/config.php ] && {
		msg_alert "Nextcloud is already installed..."
		return
	}

	# verify that the system was set up
	done_deps || return

	# install prerequisites
	TARGET="cloud"
	CERT_OU="cloud-server"
	menu_mailserver			# mailserver for nextcloud
	menu_dbserver "mysql"	# database server mysql
	menu_webserver			# webserver: apache with mod-php

	install_nextcloud		# install nextcloud
}	# end menu_nextcloud
