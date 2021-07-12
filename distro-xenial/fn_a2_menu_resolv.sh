# ------------------------------------------------------------------------------
# set /etc/resolv.conf with public dns
# https://wiki.opennic.org/api/geoip
# ------------------------------------------------------------------------------

Menu.resolv() {
	local n t="OpenNIC" r=/etc/resolv.conf
	File.backup $r

	# Getting the nearest OpenNIC servers using their geoip API
#	n=$(cmd curl -s 'https://api.opennicproject.org/geoip/' | head -3 | awk '{print "nameserver",$1}')
#	n=$(cmd wget -q4O- 'https://api.opennicproject.org/geoip/?ns&res=4&ipv=4')

	# otherwise set the freenom.world public dns
	[ -z "$n" ] && {
		t="cloudflare + freenom.world"
		n="search .\noptions timeout:2 rotate\n"
		n+="nameserver 1.1.1.1      # cloudflare\n"
		n+="nameserver 80.80.80.80  # freenom.world\n"
		n+="nameserver 1.0.0.1      # cloudflare\n"
		n+="nameserver 80.80.81.81  # freenom.world"
	}

	# write in /etc/resolv.conf
	cmd chattr -i $r	# allow file modification
	echo -e "# public dns\n$n" > $r
	cmd chattr +i $r	# disallow file modification

	Msg.info "Configuration of $t public dns completed! Now $r has:"
	sed 's|^|> |' < $r
}	# end Menu.resolv
