# ------------------------------------------------------------------------------
# install my authorized_keys, then configure SSH server & firewall
# ------------------------------------------------------------------------------

menu_ssh() {
	TARGET="${2:-${TARGET}}"

	menu_mykeys
	install_openssh "$1"
}	# end menu_ssh
