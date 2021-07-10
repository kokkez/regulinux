# ------------------------------------------------------------------------------
# install ISPConfig 3 control panel
# ------------------------------------------------------------------------------

menu_ispconfig() {
	# abort if ispconfig 3.1.x was already installed
	[ -d /usr/local/ispconfig ] && {
		Msg.warn "ISPConfig3 is already installed..."
		return
	}

	# verify that the system was set up
	done_deps || return

	# install prerequisites
	TARGET="ispconfig"
	menu_mailserver			# mailserver for ispconfig
	menu_dbserver			# database server mysql
	menu_webserver			# webserver: apache with mod-php

	# install ispconfig 3
	install_ispconfig		# install ispconfig panel
}	# end menu_ispconfig
