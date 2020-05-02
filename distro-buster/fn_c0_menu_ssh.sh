# ------------------------------------------------------------------------------
# install my authorized_keys, then configure SSH server & firewall
# ------------------------------------------------------------------------------

menu_ssh() {
	TARGET="${2:-${TARGET}}"

	menu_mykeys
	install_openssh "${1-${SSHD_PORT}}"
}	# end menu_ssh
