# ------------------------------------------------------------------------------
# install ISPConfig 3 control panel
# ------------------------------------------------------------------------------

Menu.ispconfig() {
	# metadata for OS.menu entries
	__exclude='[ -f /usr/local/ispconfig/server/server.php ]'
	__section='Target system'
	__summary="historical Control Panel, with support at $(Dye.fg.white howtoforge.com)"

	# abort if ispconfig 3.1.x was already installed
	[ -d /usr/local/ispconfig ] && {
		Msg.warn "ISPConfig3 is already installed..."
		return
	}

	# abort if "Menu.deps" was not executed
	Deps.performed || return

	# install prerequisites
	TARGET="ispconfig"
	Menu.mailserver			# mailserver for ispconfig
	Menu.dbserver			# database server mysql
	Menu.webserver			# webserver: apache with mod-php

	# install ispconfig 3
	install_ispconfig		# install ispconfig panel
}	# end Menu.ispconfig
