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

	install_motd
	install_syslogd

	# activating firewall & allowing SSH port
	install_firewall "$1"
	firewall_allow 'ssh'
}	# end Menu.deps

