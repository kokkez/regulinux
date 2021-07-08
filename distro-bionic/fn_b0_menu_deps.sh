# ------------------------------------------------------------------------------
# preparing a basic OS, ready to host applications
# ------------------------------------------------------------------------------

menu_deps() {
	local P="${1:-${SSHD_PORT}}"
	menu_ssh "${P}"

	setup_networking
	setup_resolv
	setup_tz
	OS.minimalize

	install_motd
	install_syslogd

	# activating firewall & allowing SSH port
	install_firewall "${P}"
	firewall_allow "${P}"
}	# end menu_deps

