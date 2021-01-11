# ------------------------------------------------------------------------------
# install web server for debian 9 stretch
# nginx 1.10.3 or apache2 2.4.25, with default php7.0
# ------------------------------------------------------------------------------

menu_webserver() {
	HTTP_SERVER="${1:-${HTTP_SERVER}}"
	TARGET="${2:-${TARGET}}"

	# abort if the system is not set up properly
	done_deps || return

	# install webserver (nginx or apache2)
	if [ "${HTTP_SERVER}" = "nginx" ]; then
		# install nginx (1.10.3) with php-fpm (7.0, +7.3)
		install_nginx
		install_phpfpm_nginx
	else
		HTTP_SERVER="apache2"
		# install apache2 (2.4.25) with php-fpm (7.0, +7.4)
		install_apache2
		if [ "${TARGET}" = "ispconfig" ]; then
			# php with php-fpm for ispconfig
			install_phpfpm_apache2
		else
			# php with mod-php for other installations
			install_modphp_apache2
		fi;
	fi;

	install_adminer
	install_sslcert_selfsigned
}	# end menu_webserver
