# ------------------------------------------------------------------------------
# cleanup OS minimizing the installed packages
# ------------------------------------------------------------------------------

menu_deps() {
	menu_resolv

	shell_bash
	menu_tz
	os_arrange
	install_syslogd
	install_firewall "${1-${SSHD_PORT}}"

	menu_motd
	menu_ssh "${1-${SSHD_PORT}}"

	menu_resolv
}	# end menu_deps

