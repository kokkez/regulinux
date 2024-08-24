# ------------------------------------------------------------------------------
# make the ip address static if found to be dynamic, on classic ifupdown
# ------------------------------------------------------------------------------

Net.ifupdown() {
	local g i a p=/etc/network/interfaces

	# detect v4: interface, gateway, address
	a=$(cmd ip route get $(cmd awk '{print $1}' <<< "$DNS_v4"))
	i=$(cmd grep -oP 'dev \K\S+' <<< "$a")
	g=$(cmd grep -oP 'via \K\S+' <<< "$a")
#	a=$(cmd grep -oP 'src \K\S+' <<< "$a")
	a=$(cmd ip -4 -br a s scope global | awk '{print $3}')

	# abort if already using static ip address
	cmd grep -q 'inet static' "$p" && {
		Msg.info "Network already configured with static IP: $a"
		return
	}
	# backup original file
	File.backup "$p"

	# setup /etc/network/interfaces file
	cmd cat > "$p" <<- EOF
		# This file describes the network interfaces available on your system
		# and how to activate them. For more information, see interfaces(5).

		# loopback interface
		auto lo
		iface lo inet loopback

		# ethernet interface v4
		auto $i
		iface $i inet static
		  address $a
		  gateway $g
		EOF

	# activating the configuration
#	cmd ifdown --force $i lo && cmd ifup -a
	cmd systemctl restart networking

	Msg.info "Networking changed to run with static IP: $a"
	Msg.warn "Carefully check '$p' before reboot!"
}	# end Net.ifupdown


OS.networking() {
	# abort if NOT using classic networking
	[ -e '/run/network/ifstate' ] || return
	
	# setup classic networking
	Net.ifupdown
}	# end OS.networking
