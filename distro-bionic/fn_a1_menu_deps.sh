# ------------------------------------------------------------------------------
# cleanup OS minimizing the installed packages
# ------------------------------------------------------------------------------

menu_deps() {
	local P="${1-${SSHD_PORT}}"
	menu_ssh "${P}"

	menu_networking
	menu_resolv
	menu_tz
	os_arrange

	install_motd
	install_syslogd
	install_firewall "${P}"
}	# end menu_deps

