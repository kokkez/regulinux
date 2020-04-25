# ------------------------------------------------------------------------------
# install ISPConfig 3 control panel
# ------------------------------------------------------------------------------

menu_ispconfig() {
	# abort if ispconfig 3.1.x was already installed
	[ -d /usr/local/ispconfig ] && {
		msg_alert "ISPConfig3 is already installed..."
		return
	}

	# verify that the system was set up
	done_deps || return

	# install prerequisites
	TARGET="ispconfig"
	menu_mailserver			# mailserver for ispconfig
	menu_dbserver			# database server mariadb for ispconfig
	menu_webserver			# webserver for ispconfig: apache with php-fpm

	# install ispconfig 3
	install_ispconfig		# test install ispconfig
}	# end menu_ispconfig
