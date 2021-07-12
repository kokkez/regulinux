# ------------------------------------------------------------------------------
# install nextcloud with php 7.3 for debian 10 buster	
# ------------------------------------------------------------------------------

Menu.nextcloud() {
	HTTP_SERVER="${1:-$HTTP_SERVER}"

	# abort if nextcloud is already installed
	[ -r /var/www/nextcloud/config/config.php ] && {
		Msg.warn "Nextcloud is already installed..."
		return
	}

	# abort if the system is not set up properly
	done_deps || return

	# install prerequisites
	TARGET="cloud"
	CERT_OU="cloud-server"
	Menu.mailserver			# mailserver: postfix
	Menu.dbserver			# database server: mariadb
	Menu.webserver			# webserver: nginx/apache2 with php-fpm & adminer

	install_nextcloud		# install nextcloud
}	# end Menu.nextcloud
