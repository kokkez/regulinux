# ------------------------------------------------------------------------------
# customize the Mot Of The Day screen
# ------------------------------------------------------------------------------

menu_motd() {
	[ -s "/etc/update-motd.d/*-footer" ] && return

	# verify needed packages
	is_installed "figlet" || {
		pkg_install figlet lsb-release
	}

	# copying files & make them executables
	mkdir -p /etc/update-motd.d && cd "$_"
	rm -rf ./*
	copy_to . motd/*
	chmod +x ./*

	# relink /etc/motd on pure debian
#	ln -nfs /var/run/motd /etc/motd

	Msg.info "Customization of MOTD completed!"
}	# end menu_motd
