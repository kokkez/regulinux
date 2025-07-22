# ------------------------------------------------------------------------------
# install the AntiSpam SMTP Proxy version 1 (min 384ram 1core)
# ------------------------------------------------------------------------------

Menu.assp1() {
	# metadata for OS.menu entries
	__section='Target system'
	__summary="the AntiSpam SMTP Proxy version 1 (min 768ram 1core)"

	# abort if assp is already installed
	[ -d /home/assp ] && {
		Msg.warn "ASSP v1 is already installed..."
		return
	}

	# abort if "Menu.deps" was not executed
	Deps.performed || return

	# install prerequisites
	TARGET="assp"
	CERT_OU="antispam-server"
	Menu.mailserver			# mailserver: postfix & sasl2_sql
	Menu.dbserver			# database server: mariadb
	Menu.webserver			# webserver: apache with mod-php

	install_assp "v1"		# install ASSP version 1
}	# end Menu.assp1
