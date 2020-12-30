# ------------------------------------------------------------------------------
# customize the Mot Of The Day screen
# ------------------------------------------------------------------------------

install_motd() {
	# customize the "Mot Of The Day" screen
	[ -s "/etc/update-motd.d/*-footer" ] && return

	# verify needed packages
	pkg_require figlet lsb-release
#	is_installed "figlet" || pkg_install

	# copying files & make them executables
	mkdir -p /etc/update-motd.d && cd "$_"
	rm -rf ./*
	copy_to . motd/*
	chmod +x ./*

	# relink /etc/motd on pure debian
	ln -nfs /run/motd /etc/motd

	msg_info "Customization of MOTD completed!"
}	# end install_motd
