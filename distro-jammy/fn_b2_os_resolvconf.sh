# ------------------------------------------------------------------------------
# customize resolv.conf with public dns
# https://wiki.opennic.org/api/geoip
# ------------------------------------------------------------------------------

Resolv.classic() {
	local t r='/etc/resolv.conf'
	File.backup "$r"

	# set public dns resolvers
	t=$(cat <<- EOF
		# public resolvers
		options timeout:2 rotate

		# cloudflare
		nameserver 1.1.1.1
		nameserver 1.0.0.1

		# quad9 (unfiltered)
		nameserver 9.9.9.10
		nameserver 149.112.112.112
		EOF
	)

	# install needed packages, if missing
	Pkg.requires e2fsprogs

	# write to /etc/resolv.conf
	[ -s "$r" ] && chattr -i "$r"	# allow file modification
	printf '%s\n' "$t" > "$r"
	chattr +i "$r"					# disallow file modification

	Msg.info "Configuration of public resolvers completed! Now $r has:"
	sed 's|^|> |' < "$r"
}	# end Resolv.classic


Resolv.systemd() {
	local f='/etc/systemd/resolved.conf.d'

	# if 'dns_servers.conf' already exists, then exit here
	[ -s "$f/dns_servers.conf" ] && return

	# copying files
	mkdir -p "$f"
	File.into "$f" resolved.conf.d/*

	# fully activate systemd-resolved
	cmd systemctl unmask systemd-resolved
	cmd systemctl enable systemd-resolved
	cmd systemctl restart systemd-resolved
	#cmd systemd-resolve --status

	Msg.info "Configuration of public dns completed via systemd-resolved"
}	# end Resolv.systemd


OS.resolvconf() {
	# fully deactivate systemd-resolved
	systemctl stop systemd-resolved
	systemctl disable systemd-resolved
	systemctl mask systemd-resolved

	# reactivating the classic /etc/resolv.conf
	Resolv.classic
}	# end OS.resolvconf
