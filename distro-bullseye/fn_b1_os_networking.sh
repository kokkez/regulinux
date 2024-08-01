# ------------------------------------------------------------------------------
# discovering static IP assignements
# ------------------------------------------------------------------------------

Network.ifupdown() {
	local g i a p=/etc/network/interfaces

	# detect v4: interface, gateway, address
	a=$(cmd ip route get $(cmd awk '{print $1}' <<< "$DNS_v4"))
	i=$(cmd grep -oP 'dev \K\S+' <<< "$a")
	g=$(cmd grep -oP 'via \K\S+' <<< "$a")
	a=$(cmd ip -4 -br a s scope global | awk '{print $3}')

	# install required packages
	Pkg.requires ifupdown

	# setup /etc/network/interfaces file
	cmd grep -q 'auto lo' "$p" || {
		# backup original file
		File.backup "$p"

		cmd cat > "$p" <<- EOF
			# This file describes the network interfaces available on your system
			# and how to activate them. For more information, see interfaces(5).

			# loopback interface
			auto lo
			iface lo inet loopback

			# ethernet interface
			auto $i
			iface $i inet static
			  address $a
			  gateway $g
			EOF
	}

	# activating the configuration
	cmd ifdown --force $i lo && cmd ifup -a
	cmd systemctl unmask networking
	cmd systemctl enable networking
	cmd systemctl restart networking

	# disable and remove the unwanted services
	i="systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online"
	cmd systemctl stop $i
	cmd systemctl disable $i
	cmd systemctl mask $i
	cmd apt -y purge nplan netplan.io

	Msg.info "Disabling of netplan configuration, completed"
	Msg.warn "Carefully check /etc/network/interfaces before reboot!"
}	# end Network.ifupdown


OS.networking() {
	# chech for static ip configurations
	local p=/etc/network/interfaces.d/50-cloud-init

	# cloud-init
	[ -s "$p" ] && grep -q 'inet static' $p && {
		Msg.info "Network configuration via cloud-init. Nothing to touch..."
		return
	}

	# abort if already using classic networking
	[ -e '/run/network/ifstate' ] && return

	Network.ifupdown
}	# end OS.networking
