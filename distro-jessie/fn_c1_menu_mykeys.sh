# ------------------------------------------------------------------------------
# install my authorized_keys, copying or appending them
# ------------------------------------------------------------------------------

menu_mykeys() {
	mkdir -p ~/.ssh && cd "$_"
	cmd chmod 0700 ~/.ssh

	# copy file
	[ -r authorized_keys ] || File.into . ssh/authorized_keys

	# append content
	grep -q "kokkez" authorized_keys || cat "${ENV_files}/ssh/authorized_keys" >> authorized_keys

	cmd chmod 0600 authorized_keys
	Msg.info "Installation of my authorized_keys completed!"
}	# end menu_mykeys
