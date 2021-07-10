# ------------------------------------------------------------------------------
# install ISPConfig 3 control panel
# ------------------------------------------------------------------------------

menu_ispconfig() {
	HTTP_SERVER="${1:-${HTTP_SERVER}}"

	# abort if ispconfig is already installed
	has_ispconfig && {
		Msg.warn "ISPConfig3 is already installed..."
		return
	}

	# abort if the system is not set up properly
	done_deps || return

	# install prerequisites
	TARGET="ispconfig"
	menu_mailserver			# mailserver: postfix + dovecot
	menu_dbserver			# database server: mariadb
	menu_webserver			# webserver: nginx/apache2 with php-fpm & adminer

	# install needed software for ispconfig
	install_pureftpd
	install_webstats
#	install_jailkit
	install_fail2ban

	# install ispconfig panel
	install_ispconfig
}	# end menu_ispconfig
