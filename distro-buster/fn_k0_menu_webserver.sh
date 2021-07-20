# ------------------------------------------------------------------------------
# install web server for debian 10 buster
# nginx 1.14.2 or apache2 2.4.38, with default php7.3
# ------------------------------------------------------------------------------

Menu.webserver() {
	# $2: target system to build, optional
	HTTP_SERVER="${1:-$HTTP_SERVER}"
	TARGET="${2:-$TARGET}"

	# abort if "Menu.deps" was not executed
	Deps.performed || return

	# install webserver (nginx or apache2)
	if [ "$HTTP_SERVER" = "nginx" ]; then
		install_nginx
		install_phpfpm_nginx				# php-fpm for all targets
	else
		HTTP_SERVER="apache2"
		install_apache2
		if [ "$TARGET" = "ispconfig" ]; then
			install_phpfpm_apache2			# php-fpm for ispconfig
		else
			install_modphp_apache2			# mod-php for other targets
		fi;
	fi;

	install_adminer
	install_sslcert_selfsigned
}	# end Menu.webserver
