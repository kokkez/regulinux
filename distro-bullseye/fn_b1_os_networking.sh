# ------------------------------------------------------------------------------
# discovering static IP assignements
# ------------------------------------------------------------------------------

Net.info() {
	# return values for the network interface connected to the Internet
	# $1 - optional, desired result: if, mac, cidr, ip, gw, cidr6, ip6, gw6
	local if=$(cmd ip r get 1 | cmd grep -oP 'dev \K\S+')
	local mac=$(cmd ip -br l show "$if" | cmd awk '{print $3}')
	local c4=$(cmd ip -br -4 a show "$if" | cmd awk '{print $3}')
	local g4=$(cmd ip r get 1 | cmd grep -oP 'via \K\S+')
	local a4=${c4%%/*}

	# check if IPv6 is enabled
	local g6 a6 v=$(cmd ip a s scope global)
	local c6=$(cmd grep -oP 'inet6 \K\S+' <<< "$v")
	if [ -n "$c6" ]; then
		g6=$(cmd ip r get :: | cmd grep -oP 'via \K\S+')
		a6=${c6%%/*}
	fi

	case "$1" in
		m*)   echo ${mac,,} ;;
		c*6*) echo $c6 ;;
		c*)   echo $c4 ;;
		g*6*) echo $g6 ;;
		g*)   echo $g4 ;;
		i*6*) echo $a6 ;;
		if*)  echo $if ;;
		i*)   echo $a4 ;;
		*)    cat <<- EOF
			> Network Interface : $if
			> MAC Address       : ${mac,,}
			----------------------------------------------------------
			> IPv4 CIDR         : $c4
			> IPv4 Address      : $a4
			> IPv4 Gateway      : $g4
			----------------------------------------------------------
			> IPv6 CIDR         : ${c6:-N/A}
			> IPv6 Address      : ${a6:-N/A}
			> IPv6 Gateway      : ${g6:-N/A}
			----------------------------------------------------------
			EOF
	esac
}	# end Net.info


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
