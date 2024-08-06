# ------------------------------------------------------------------------------
# install Jailkit
# ------------------------------------------------------------------------------

install_jailkit() {
	# important: Jailkit must be installed before ISPConfig3, it cannot be installed afterwards
	[ -d "/usr/local/ispconfig" ] && {
		Msg.warn "ISPConfig3 is already installed, Jailkit will be skipped..."
		return
	}

	# check if Jailkit is installed already
	Cmd.usable "jk_list" || {
		Msg.info "Installing Jailkit..."
		dpkg -i $( File.path jailkit_2.19-1_amd64.deb )
		Msg.info "Installation of Jailkit completed!"
	}
}	# end install_jailkit
