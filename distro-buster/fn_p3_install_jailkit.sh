# ------------------------------------------------------------------------------
# install Jailkit
# ------------------------------------------------------------------------------

install_jailkit() {
	# important: Jailkit must be installed before ISPConfig3, it cannot be installed afterwards
	has_ispconfig && {
		msg_alert "ISPConfig3 is already installed, Jailkit will be skipped..."
		return
	}

	# check if Jailkit is installed already
	is_available "jk_list" || {
		msg_info "Installing Jailkit..."
		pkg_require python
		dpkg -i ${MyFILES}/jailkit_2.19-1_amd64.deb
		msg_info "Installation of Jailkit completed!"
	}
}	# end install_jailkit
