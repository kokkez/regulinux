# ------------------------------------------------------------------------------
# install web server
# ------------------------------------------------------------------------------

menu_webserver() {
	TARGET="${1-${TARGET}}"

	# verify that the system was set up properly
	done_deps || return

	if [ "${TARGET}" = "ispconfig" ]; then
		# apache2 with php5-fpm for ispconfig
		install_apache2
		install_phpfpm

		install_selfsigned_sslcert
		install_pureftpd
		install_adminer
		install_webstats

		install_jailkit
		install_fail2ban

	else
		# apache2 with mod-php5 for assp & clouds
		install_apache2_modphp
		install_selfsigned_sslcert
		install_adminer
	fi;
}	# end menu_webserver
