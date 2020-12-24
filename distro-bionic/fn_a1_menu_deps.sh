# ------------------------------------------------------------------------------
# cleanup OS minimizing the installed packages
# ------------------------------------------------------------------------------

menu_deps() {
	local P="${1-${SSHD_PORT}}"

	# sanity check, stop here if my key is missing
	grep -q "kokkez" ~/.ssh/authorized_keys || {
		msg_error "Missing 'kokkez' private key in '~/.ssh/authorized_keys'"
	}

	menu_networking
	menu_resolv
	shell_bash
	menu_tz
	os_arrange
	install_syslogd
	install_firewall "${P}"

	menu_motd
	menu_ssh "${P}"
}	# end menu_deps

