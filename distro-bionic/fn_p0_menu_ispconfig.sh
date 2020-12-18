# ------------------------------------------------------------------------------
# install ISPConfig 3 control panel
# ------------------------------------------------------------------------------

menu_ispconfig() {
	HTTP_SERVER="${1:-apache}"

	# abort if ispconfig 3.1.x was already installed
	[ -d /usr/local/ispconfig ] && {
		msg_alert "ISPConfig3 is already installed..."
		return
	}

	# verify that the system was set up
	done_deps || return

	# install prerequisites
	TARGET="ispconfig"
	menu_mailserver			# mailserver: postfix + dovecot
	menu_dbserver			# database server: mariadb

	if [ "${HTTP_SERVER}" = "nginx" ]; then
		# install nginx webserver with php 7.3
		install_nginx
		install_php73_fpm_nginx
		install_selfsigned_sslcert_nginx
	else
		HTTP_SERVER="apache"
		# install apache2 webserver with php 7.4
		install_apache2
		install_php74_fpm
		install_selfsigned_sslcert
	fi;

	install_adminer
	install_pureftpd
	install_webstats
#	install_jailkit
	install_fail2ban

	# install ispconfig 3
	install_ispconfig		# install ispconfig panel
}	# end menu_ispconfig
