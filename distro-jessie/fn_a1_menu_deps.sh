# ------------------------------------------------------------------------------
# cleanup OS minimizing the installed packages
# ------------------------------------------------------------------------------

Menu.deps() {
	# $1: ssh port number
	Menu.resolv

	shell_bash
	Menu.tz
	OS.minimalize
	install_syslogd
	Install.firewall "$1"

	Menu.motd
	Menu.ssh "$1"

	Menu.resolv
}	# end Menu.deps

