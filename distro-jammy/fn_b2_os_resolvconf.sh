# ------------------------------------------------------------------------------
# customize resolv.conf with public dns
# https://wiki.opennic.org/api/geoip
# ------------------------------------------------------------------------------

Resolv.classic() {
	local t r='/etc/resolv.conf'
	File.backup "$r"
	[ -L "$r" ] && rm -f "$r"

	# set public dns resolvers
	set -- $DNS_v4
	t=$(cat <<- EOF
		# public resolvers
		options timeout:2 rotate

		# cloudflare
		nameserver $1
		nameserver $3

		# quad9 (unfiltered)
		nameserver $2
		nameserver $4
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


OS.resolvconf() {
	# fully deactivate systemd-resolved
	systemctl stop systemd-resolved
	systemctl disable systemd-resolved
	systemctl mask systemd-resolved

	# reactivating the classic /etc/resolv.conf
	Resolv.classic
}	# end OS.resolvconf
