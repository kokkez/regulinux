# ------------------------------------------------------------------------------
# install web server
# ------------------------------------------------------------------------------

menu_webserver() {
	TARGET="${1-${TARGET}}"

	# verify that the system was set up properly
	done_deps || return

	# install apache2 webserver
	install_apache2

	# install php based on TARGET
	if [ "${TARGET}" = "ispconfig" ]; then
		# php with php5-fpm & php-fcgi for ispconfig
		install_php_fpm

		install_selfsigned_sslcert
		install_pureftpd
		install_adminer
		install_webstats

		install_jailkit
		install_fail2ban

	else
		[ -z "${TARGET}" ] && TARGET="cloud"
		# php with mod-php for basic installation
		install_php_modphp

		install_selfsigned_sslcert
		install_adminer
	fi;
}	# end menu_webserver
