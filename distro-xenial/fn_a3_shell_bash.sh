# ------------------------------------------------------------------------------
# set bash as the default shell
# ------------------------------------------------------------------------------

shell_bash() {
	debconf-set-selections <<< "dash dash/sh boolean false"
	dpkg-reconfigure -f noninteractive dash

	[ -f ~/.bashrc ] || File.into ~ .bashrc
	. ~/.bashrc

	Msg.info "Changing default shell to BASH, completed"
}	# end shell_bash
