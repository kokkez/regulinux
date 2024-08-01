# ------------------------------------------------------------------------------
# customize resolv.conf with public dns
# https://wiki.opennic.org/api/geoip
# ------------------------------------------------------------------------------

Resolv.classic() {
	local n t r='/etc/resolv.conf'
	File.backup "$r"

	# set known public dns
	t="cloudflare + quad9"
	n="search .\noptions timeout:2 rotate\n"
	n+="nameserver $(cmd awk '{print $1}' <<< "$DNS_v4")  # cloudflare\n"
	n+="nameserver $(cmd awk '{print $2}' <<< "$DNS_v4")  # quad9\n"
	n+="nameserver $(cmd awk '{print $3}' <<< "$DNS_v4")  # cloudflare\n"
	n+="nameserver $(cmd awk '{print $4}' <<< "$DNS_v4")  # quad9"

	# install needed packages, if missing
	Pkg.requires e2fsprogs

	# write to /etc/resolv.conf
	[ -s "$r" ] && cmd chattr -i "$r"	# allow file modification
	echo -e "# public dns\n$n" > "$r"
	cmd chattr +i "$r"					# disallow file modification

	Msg.info "Configuration of $t public dns completed! Now $r has:"
	sed 's|^|> |' < "$r"
}	# end Resolv.classic


Resolv.systemd() {
	# simply delete the symlink
	rm -rf /etc/resolv.conf

	# then recreate the file
	Resolv.classic
}	# end Resolv.systemd


OS.resolvconf() {
	# if resolv.conf is a valid symlink, then setup via systemd
	File.islink '/etc/resolv.conf' \
		&& Resolv.systemd \
		|| Resolv.classic
}	# end OS.resolvconf
