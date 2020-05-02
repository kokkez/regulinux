# ------------------------------------------------------------------------------
# set bash as the default shell
# ------------------------------------------------------------------------------

shell_bash() {
	debconf-set-selections <<< "dash dash/sh boolean false"
	dpkg-reconfigure -f noninteractive dash

	[ -f ~/.bashrc ] || copy_to ~ .bashrc

	msg_info "Changing default shell to BASH, completed"
}	# end shell_bash
