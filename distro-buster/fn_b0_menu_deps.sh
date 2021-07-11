# ------------------------------------------------------------------------------
# preparing a basic OS, ready to host applications
# ------------------------------------------------------------------------------

menu_deps() {
	# $1: ssh port number
	menu_ssh "$1"

	setup_networking
	setup_resolv
	setup_tz
	OS.minimalize

	install_motd
	install_syslogd

	# activating firewall & allowing SSH port
	install_firewall "$1"
	firewall_allow "$1"
}	# end menu_deps

