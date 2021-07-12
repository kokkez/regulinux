# ------------------------------------------------------------------------------
# install nextcloud for debian 8 with php 5.6
# ------------------------------------------------------------------------------

Menu.nextcloud() {
	[ -r /var/www/nextcloud/config/config.php ] && {
		Msg.warn "Nextcloud is already installed..."
		return
	}

	# verify that the system was set up
	done_deps || return

	# install prerequisites
	TARGET="cloud"
	CERT_OU="cloud-server"
	Menu.mailserver			# mailserver for nextcloud
	Menu.dbserver "mysql"	# database server mysql
	Menu.webserver			# webserver: apache with mod-php

	install_nextcloud		# install nextcloud
}	# end Menu.nextcloud
