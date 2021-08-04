# ------------------------------------------------------------------------------
# preparing a basic OS, ready to host applications
# ------------------------------------------------------------------------------

Menu.deps() {
	# $1: ssh port number, optional
	Menu.ssh "$1"

	setup_networking
	setup_resolv
	setup_tz
	OS.minimalize

	Install.motd
	Install.syslogd

	# activating firewall, allowing SSH port
	Install.firewall "$1"
}	# end Menu.deps

