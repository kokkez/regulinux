# ------------------------------------------------------------------------------
# customize the Mot Of The Day screen
# ------------------------------------------------------------------------------

Menu.motd() {
	[ -s "/etc/update-motd.d/*-footer" ] && return

	# verify needed packages
	Pkg.installed "figlet" || {
		Pkg.install figlet lsb-release
	}

	# copying files & make them executables
	mkdir -p /etc/update-motd.d && cd "$_"
	rm -rf ./*
	File.into . motd/*
	chmod +x ./*

	# relink /etc/motd on pure debian
	ln -nfs /run/motd /etc/motd

	Msg.info "Customization of MOTD completed!"
}	# end Menu.motd
