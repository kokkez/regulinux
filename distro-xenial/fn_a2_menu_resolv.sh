# ------------------------------------------------------------------------------
# set /etc/resolv.conf with public dns
# https://wiki.opennic.org/api/geoip
# ------------------------------------------------------------------------------

menu_resolv() {
	local N T="OpenNIC" R=/etc/resolv.conf
	backup_file ${R}

	# Getting the nearest OpenNIC servers using their geoip API
#	N=$(cmd curl -s 'https://api.opennicproject.org/geoip/' | head -3 | awk '{print "nameserver",$1}')
#	N=$(cmd wget -q4O- 'https://api.opennicproject.org/geoip/?ns&res=4&ipv=4')

	# otherwise set the freenom.world public dns
	[ -z "${N}" ] && {
		T="cloudflare + freenom.world"
		N="search .\noptions timeout:2 rotate\n"
		N+="nameserver 1.1.1.1      # cloudflare\n"
		N+="nameserver 80.80.80.80  # freenom.world\n"
		N+="nameserver 1.0.0.1      # cloudflare\n"
		N+="nameserver 80.80.81.81  # freenom.world"
	}

	# write in /etc/resolv.conf
	cmd chattr -i ${R}	# allow file modification
	echo -e "# public dns\n${N}" > ${R}
	cmd chattr +i ${R}	# disallow file modification

	Msg.info "Configuration of ${T} public dns completed! Now ${R} has:"
	sed 's|^|> |' < ${R}
}	# end menu_resolv
