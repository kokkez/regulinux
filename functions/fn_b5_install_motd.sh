# ------------------------------------------------------------------------------
# install and customize the "Mot Of The Day" screen
# ------------------------------------------------------------------------------

Install.motd.old() {
	local p='/etc/update-motd.d'

	# abort if MOTD is already installed
	[ -s "$p/*-footer" ] && return

	# install needed packages, if missing
	Pkg.requires figlet lsb-release

	# copying files & make them executables
	mkdir -p "$p"
	rm -rf $p/*
	File.into "$p" motd/*
	chmod +x $p/*

	# remove /etc/motd on pure debian
	cmd rm -f /etc/motd

	# relink /etc/motd on debian jessie
	[ "$ENV_release" = "debian-8" ] && ln -nfs /run/motd /etc/motd

	Msg.info "Customization of MOTD completed!"
}	# end Install.motd.old


Install.motd() {
	# from 2024 onward we use a single file into /etc/profiles.d/
	# so only when really connected via terminal we have the nice MOTD screen
	local p='/etc/profile.d'

	# abort if MOTD is already installed
	[ -s "$p/motd-console.sh" ] && return

	# install needed packages, if missing
	Pkg.requires figlet lsb-release

	# simply copying file
	File.into "$p" motd/motd-console.sh

	# always empty the motd folder
	rm -rf /etc/update-motd.d/*
	cmd rm -f /etc/motd		# remove this on pure debian

	Msg.info "Installation of MOTD completed!"
}	# end Install.motd
