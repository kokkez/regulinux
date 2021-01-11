# ------------------------------------------------------------------------------
# customize resolv.conf with public dns
# https://wiki.opennic.org/api/geoip
# ------------------------------------------------------------------------------

resolv_via_resolvconf() {
	local N T R=/etc/resolv.conf
	backup_file "${R}"

	# set known public dns
	T="cloudflare + freenom.world"
	N="search .\noptions timeout:2 rotate\n"
	N+="nameserver 1.1.1.1      # cloudflare\n"
	N+="nameserver 80.80.80.80  # freenom.world\n"
	N+="nameserver 1.0.0.1      # cloudflare\n"
	N+="nameserver 80.80.81.81  # freenom.world"

	# verify needed packages
	pkg_require e2fsprogs

	# write to /etc/resolv.conf
	[ -s "${R}" ] && cmd chattr -i "${R}"	# allow file modification
	echo -e "# public dns\n${N}" > "${R}"
	cmd chattr +i "${R}"					# disallow file modification

	msg_info "Configuration of ${T} public dns completed! Now ${R} has:"
	sed 's|^|> |' < ${R}
}	# end resolv_via_resolvconf


resolv_via_systemd() {
	# simply delete the symlink
	rm -rf /etc/resolv.conf

	# then recreate the file
	resolv_via_resolvconf
}	# end resolv_via_systemd


setup_resolv() {
	# if resolv.conf is a valid symlink, then setup via systemd
	is_symlink '/etc/resolv.conf' \
		&& resolv_via_systemd \
		|| resolv_via_resolvconf
}	# end setup_resolv
