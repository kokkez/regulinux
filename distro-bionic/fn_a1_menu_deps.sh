# ------------------------------------------------------------------------------
# cleanup OS minimizing the installed packages
# ------------------------------------------------------------------------------

menu_deps() {
	local P="${1-${SSHD_PORT}}"

	menu_resolv
	shell_bash
	menu_tz
	os_arrange
	install_syslogd
	install_firewall "${P}"

	menu_motd
	menu_ssh "${P}"
}	# end menu_deps

