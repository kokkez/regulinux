# ------------------------------------------------------------------------------
# set bash as the default shell
# ------------------------------------------------------------------------------

shell_bash() {
	debconf-set-selections <<< "dash dash/sh boolean false"
	dpkg-reconfigure -f noninteractive dash

	[ -f ~/.bashrc ] || copy_to ~ .bashrc

	Msg.info "Bash is now set as the default shell"
}	# end shell_bash
