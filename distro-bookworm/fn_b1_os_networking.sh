# ------------------------------------------------------------------------------
# make the ip address static if found to be dynamic, on classic ifupdown
# ------------------------------------------------------------------------------

Net.hosts() {
	# debianize /etc/hosts, dropping public ipv4 & assign hostname to 127.0.1.1
	local a="$(Menu.inet ip)" p=/etc/hosts

	# always backup =]
	File.backup "$p"

	# remove line with current ipv4
	grep -q "$a" "$p" && {
		Msg.info "Deleting line with current IPv4 ($a) from $p ..."
		cmd sed -i "/$a/d" "$p"
	}

	# add line for fqdn hostname
	grep -q '127.0.1.1' "$p" || {
		Msg.info "Appending hostname line in $p ..."
		cmd sed -i "/127.0.0.1/a 127.0.1.1\t$HOST_FQDN" "$p"
	}
}	# end Net.hosts


Net.ifupdown() {
	local g i a p=/etc/network/interfaces

	# detect v4: interface, gateway, address
	i=$(Menu.inet if)
	g=$(Menu.inet gw)
	a=$(Menu.inet cidr)

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
	# chech for static ip configurations
	local p=/etc/network/interfaces.d/50-cloud-init

	# debianize /etc/hosts, drop line with ipv4 & add line: 127.0.1.1 hostname
	Net.hosts
	cmd hostnamectl hostname "$HOST_FQDN"

	# chech for cloud-init
	[ -s "$p" ] && grep -q 'inet static' $p && {
		Msg.info "Network configuration via cloud-init. Nothing to touch..."
		return
	}

	# setup classic networking if not already in use
	[ -e '/run/network/ifstate' ] || Net.ifupdown
}	# end OS.networking
