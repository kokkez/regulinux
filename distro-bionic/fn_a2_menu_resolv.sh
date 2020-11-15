# ------------------------------------------------------------------------------
# set /etc/resolv.conf with public dns
# https://wiki.opennic.org/api/geoip
# ------------------------------------------------------------------------------

resolv_via_systemd() {
	# copying files
	mkdir -p "/etc/systemd/resolved.conf.d" && cd "$_"
	copy_to . resolved.conf.d/*

	# fully activate systemd-resolved
	cmd systemctl unmask systemd-resolved
	cmd systemctl enable systemd-resolved
	cmd systemctl restart systemd-resolved
	#cmd systemd-resolve --status

	msg_info "Configuration of public dns completed via systemd-resolved"
}	# end resolv_via_systemd


resolv_via_resolvconf() {
	local N T R="${1:-/etc/resolv.conf}"
	backup_file "${R}"

	# set known public dns
	T="cloudflare + freenom.world"
	N="search .\noptions timeout:2 rotate\n"
	N+="nameserver 1.1.1.1      # cloudflare\n"
	N+="nameserver 80.80.80.80  # freenom.world\n"
	N+="nameserver 1.0.0.1      # cloudflare\n"
	N+="nameserver 80.80.81.81  # freenom.world"

	# write in /etc/resolv.conf
	cmd chattr -i ${R}	# allow file modification
	echo -e "# public dns\n${N}" > ${R}
	cmd chattr +i ${R}	# disallow file modification

	msg_info "Configuration of ${T} public dns completed! Now ${R} has:"
	sed 's|^|> |' < ${R}
}	# end resolv_via_resolvconf


menu_resolv() {
	local R=/etc/resolv.conf

	# if resolv.conf is a valid symlink, then setup via systemd
	is_symlink "${R}" && {
		resolv_via_systemd
	} || {
		resolv_via_resolvconf "${R}"
	}
}	# end menu_resolv
