# ------------------------------------------------------------------------------
# install and customize the "Mot Of The Day" screen
# ------------------------------------------------------------------------------

Install.motd() {
	local p=/etc/update-motd.d

	# abort if MOTD is already installed
	[ -s "$p/*-footer" ] && return

	# install needed packages, if missing
	Pkg.requires figlet lsb-release

	# copying files & make them executables
	mkdir -p "$p"
	rm -rf $p/*
	File.into $p motd/*
	chmod +x $p/*

	# remove /etc/motd on pure debian
	[ "$ENV_product" = "debian" ] && rm -f /etc/motd

	# relink /etc/motd on debian jessie
	[ "$ENV_release" = "debian-8" ] && ln -nfs /run/motd /etc/motd

	Msg.info "Customization of MOTD completed!"
}	# end Install.motd
