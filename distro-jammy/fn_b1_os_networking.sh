# ------------------------------------------------------------------------------
# disable and remove netplan networking system in favor of the classic ifupdown
# ------------------------------------------------------------------------------

OS.networking() {
	# abort if already using classic networking
	[ -e '/run/network/ifstate' ] && return

	# detect: interface, address, gateway
	local p i a g
	p='/etc/network/interfaces'
	i=$(Net.info if)
	a=$(Net.info ip4)
	g=$(Net.info gw4)

	# install required packages
	Pkg.requires ifupdown

	# setup /etc/network/interfaces file
	grep -q 'auto lo' "$p" || {
		# backup original file
		File.backup "$p"

		cat > "$p" <<- EOF
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
	}

	# activating the configuration
	ifdown --force "$i" && ifup -a
	systemctl unmask networking
	systemctl enable networking
	systemctl restart networking

	# disable and remove the unwanted services
	i="systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online"
	systemctl stop $i
	systemctl disable $i
	systemctl mask $i
	apt -y purge nplan netplan.io

	Msg.info "Disabling of netplan configuration is completed"
	Msg.warn "Carefully check /etc/network/interfaces before reboot!"
}	# end OS.networking

