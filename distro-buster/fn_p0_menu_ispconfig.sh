# ------------------------------------------------------------------------------
# install ISPConfig 3 control panel
# ------------------------------------------------------------------------------

Menu.ispconfig() {
	# metadata for OS.menu entries
	__exclude='[ -f /usr/local/ispconfig/server/server.php ]'
	__section='Target system'
	__summary="historical Control Panel, with support at $(Dye.fg.white howtoforge.com)"

	HTTP_SERVER="${1:-$HTTP_SERVER}"

	# abort if ispconfig is already installed
	ISPConfig.installed && {
		Msg.warn "ISPConfig3 is already installed..."
		return
	}

	# abort if "Menu.deps" was not executed
	Deps.performed || return

	# install prerequisites
	TARGET="ispconfig"
	Menu.mailserver			# mailserver: postfix + dovecot
	Menu.dbserver			# database server: mariadb
	Menu.webserver			# webserver: nginx/apache2 with php-fpm & adminer

	# install needed software for ispconfig
	install_pureftpd
	Install.webstats
#	install_jailkit
	install_fail2ban

	# install ispconfig panel
	install_ispconfig
}	# end Menu.ispconfig
