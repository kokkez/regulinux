# ------------------------------------------------------------------------------
# install web server
# ------------------------------------------------------------------------------

Menu.webserver() {
	# $1: target system to build, optional
	TARGET="${1:-$TARGET}"

	# verify that the system was set up properly
	done_deps || return

	# install apache2 webserver
	install_apache2

	# install php based on TARGET
	if [ "$TARGET" = "ispconfig" ]; then
		# php with php-fpm for ispconfig
#		install_php7x_fpm
		install_php74_fpm

		install_selfsigned_sslcert
		install_pureftpd
		install_adminer
		Install.webstats

		install_jailkit
		install_fail2ban

	else
		[ -z "$TARGET" ] && TARGET="cloud"
		# php with mod-php for basic installation
		install_php_modphp

		install_selfsigned_sslcert
		install_adminer
	fi;
}	# end Menu.webserver
