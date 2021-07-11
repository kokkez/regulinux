# ------------------------------------------------------------------------------
# cleanup OS minimizing the installed packages
# ------------------------------------------------------------------------------

menu_deps() {
	# $1: ssh port number
	menu_resolv

	shell_bash
	menu_tz
	OS.minimalize
	install_syslogd
	install_firewall "$1"

	menu_motd
	menu_ssh "$1"

	menu_resolv
}	# end menu_deps

