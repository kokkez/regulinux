# ------------------------------------------------------------------------------
# install nextcloud for ubuntu 18.04 with php 7.x
# ------------------------------------------------------------------------------

menu_nextcloud() {
	# test that was not already installed
	[ -r /var/www/nextcloud/config/config.php ] && {
		msg_alert "Nextcloud is already installed..."
		return
	}

	# verify that the system was set up
	done_deps || return

	# install prerequisites
	TARGET="cloud"
	CERT_OU="cloud-server"
	menu_mailserver			# mailserver: postfix
	menu_dbserver			# database server: mariadb

	# install apache2 webserver with php 7.4
	install_apache2
	install_php74_fpm
	install_selfsigned_sslcert
	install_adminer

	install_nextcloud 		# install nextcloud
	install_varnish			# install the cache system
}	# end menu_nextcloud
