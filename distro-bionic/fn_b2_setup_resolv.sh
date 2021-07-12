# ------------------------------------------------------------------------------
# customize resolv.conf with public dns
# https://wiki.opennic.org/api/geoip
# ------------------------------------------------------------------------------

resolv_via_resolvconf() {
	local n t r=/etc/resolv.conf
	File.backup "$r"

	# set known public dns
	t="cloudflare + freenom.world"
	n="search .\noptions timeout:2 rotate\n"
	n+="nameserver 1.1.1.1      # cloudflare\n"
	n+="nameserver 80.80.80.80  # freenom.world\n"
	n+="nameserver 1.0.0.1      # cloudflare\n"
	n+="nameserver 80.80.81.81  # freenom.world"

	# verify needed packages
	Pkg.requires e2fsprogs

	# write to /etc/resolv.conf
	[ -s "$r" ] && cmd chattr -i "$r"	# allow file modification
	echo -e "# public dns\n$n" > "$r"
	cmd chattr +i "$r"					# disallow file modification

	Msg.info "Configuration of $t public dns completed! Now $r has:"
	sed 's|^|> |' < $r
}	# end resolv_via_resolvconf


resolv_via_systemd() {
	local f=/etc/systemd/resolved.conf.d

	# if 'dns_servers.conf' already exists, then exit here
	[ -s "$f/dns_servers.conf" ] && return

	# copying files
	mkdir -p "$f" && cd "$_"
	File.into . resolved.conf.d/*

	# fully activate systemd-resolved
	cmd systemctl unmask systemd-resolved
	cmd systemctl enable systemd-resolved
	cmd systemctl restart systemd-resolved
	#cmd systemd-resolve --status

	Msg.info "Configuration of public dns completed via systemd-resolved"
}	# end resolv_via_systemd


setup_resolv() {
	# if resolv.conf is a valid symlink, then setup via systemd
	File.islink '/etc/resolv.conf' \
		&& resolv_via_systemd \
		|| resolv_via_resolvconf
}	# end setup_resolv
