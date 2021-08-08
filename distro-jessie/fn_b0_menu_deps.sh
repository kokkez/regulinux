# ------------------------------------------------------------------------------
# preparing a basic OS, ready to host applications
# ------------------------------------------------------------------------------

Menu.deps() {
	# $1: ssh port number, optional
	Menu.root "$1"

	OS.networking
	OS.resolvconf
	OS.timedate
	OS.minimalize

	Install.motd
	Install.syslogd

	# activating firewall, allowing SSH port
	Install.firewall "$1"
}	# end Menu.deps
