# ------------------------------------------------------------------------------
# install my authorized_keys, then configure SSH server & firewall
# ------------------------------------------------------------------------------

Menu.ssh() {
	# $1: ssh port number, optional

	Menu.mykeys
	install_openssh "$1"
}	# end Menu.ssh
