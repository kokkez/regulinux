# ------------------------------------------------------------------------------
# install my authorized_keys, then configure SSH server & firewall
# ------------------------------------------------------------------------------

menu_ssh() {
	# $1: ssh port number, optional

	menu_mykeys
	install_openssh "$1"
}	# end menu_ssh
