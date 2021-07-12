# ------------------------------------------------------------------------------
# install ISPConfig 3 control panel
# ------------------------------------------------------------------------------

Menu.ispconfig() {
	# abort if ispconfig 3.1.x was already installed
	[ -d /usr/local/ispconfig ] && {
		Msg.warn "ISPConfig3 is already installed..."
		return
	}

	# verify that the system was set up
	done_deps || return

	# install prerequisites
	TARGET="ispconfig"
	Menu.mailserver			# mailserver: postfix + dovecot
	Menu.dbserver			# database server: mariadb
	Menu.webserver			# webserver: apache with php-fpm

	# install ispconfig 3
	install_ispconfig		# install ispconfig panel
}	# end Menu.ispconfig
