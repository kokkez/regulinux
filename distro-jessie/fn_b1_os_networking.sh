# ------------------------------------------------------------------------------
# make the ip address static if found to be dynamic, on classic ifupdown
# ------------------------------------------------------------------------------

OS.networking() {
	# abort if NOT using classic networking
	[ -e '/run/network/ifstate' ] || return

	# detect: interface, address, gateway
	local p i a g="$(cmd ip route get 1.1.1.1)"
	i=$(cmd grep -oP '\s+dev\s+\K\w+' <<< "$g")
	a=$(cmd grep -oP '\s+src\s+\K[\w\.]+' <<< "$g")
	g=$(cmd grep -oP '\s+via\s+\K[\w\.]+' <<< "$g")
	p='/etc/network/interfaces'

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

		# ethernet interface
		auto $i
		iface $i inet static
		  address $a/24
		  gateway $g
		EOF

	# activating the configuration
#	cmd ifdown --force $i lo && cmd ifup -a
	cmd systemctl restart networking

	Msg.info "Networking changed to run with static IP: $a"
	Msg.warn "Carefully check '$p' before reboot!"
}	# end OS.networking
