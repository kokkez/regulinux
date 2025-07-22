# ------------------------------------------------------------------------------
# install nextcloud for debian 8 with php 5.6
# ------------------------------------------------------------------------------

Menu.nextcloud() {
	# metadata for OS.menu entries
	__exclude='[ -s /var/www/nextcloud/config/config.php ]'
	__section='Others applications'
	__summary="on-premises file sharing and collaboration platform"

	[ -r /var/www/nextcloud/config/config.php ] && {
		Msg.warn "Nextcloud is already installed..."
		return
	}

	# abort if "Menu.deps" was not executed
	Deps.performed || return

	# install prerequisites
	TARGET="cloud"
	CERT_OU="cloud-server"
	Menu.mailserver			# mailserver for nextcloud
	Menu.dbserver "mysql"	# database server mysql
	Menu.webserver			# webserver: apache with mod-php

	install_nextcloud		# install nextcloud
}	# end Menu.nextcloud
