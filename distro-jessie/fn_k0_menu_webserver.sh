# ------------------------------------------------------------------------------
# install web server
# ------------------------------------------------------------------------------

Menu.webserver() {
	TARGET="${1-$TARGET}"

	# abort if "Menu.deps" was not executed
	Deps.performed || return

	if [ "$TARGET" = "ispconfig" ]; then
		# apache2 with php5-fpm for ispconfig
		install_apache2
		install_phpfpm

		install_selfsigned_sslcert
		install_pureftpd
		install_adminer
		Install.webstats

		install_jailkit
		install_fail2ban

	else
		# apache2 with mod-php5 for assp & clouds
		install_apache2_modphp
		install_selfsigned_sslcert
		install_adminer
	fi;
}	# end Menu.webserver
