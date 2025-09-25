# ------------------------------------------------------------------------------
# disable and remove netplan networking system in favor of the classic ifupdown
# ------------------------------------------------------------------------------

Net.info() {
	# return values for the network interface connected to the Internet
	# $1 - optional, desired result: if, mac, cidr, ip, gw, cidr6, ip6, gw6

	# interface name and mac address
	local if=$(ip r g 1 | grep -oP 'dev \K\S+')
	local mac=$(< /sys/class/net/$if/address)
	mac=${mac:-00:00:00:00:00:00}

	# ipv4 cidr, gateway and address
	local c4=$(ip -4 -br a s $if | awk '{print $3; exit}')
	local g4=$(ip r g 1 | grep -oP 'via \K\S+')
	g4=${g4:-0.0.0.0}
	local a4=${c4%%/*}

	# calculate subnet mask
	local sm=${c4##*/}	# strip everything until /
	sm=$((0xffffffff << (32 - sm)))
	sm=$(printf '%d.%d.%d.%d\n' $((sm >> 24 & 255)) $((sm >> 16 & 255)) $((sm >> 8 & 255)) $((sm & 255)))

	# check if IPv6 is enabled
	local g6 a6 v=$(ip a s scope global)
	local c6=$(grep -oP 'inet6 \K\S+' <<< "$v")
	if [ -n "$c6" ]; then
		g6=$(ip r get :: | grep -oP 'via \K\S+')
		a6=${c6%%/*}
	fi

	case "$1" in
		m*)   echo $mac ;;
		c*6*) echo $c6 ;;
		c*)   echo $c4 ;;
		g*6*) echo $g6 ;;
		g*)   echo $g4 ;;
		i*6*) echo $a6 ;;
		if*)  echo $if ;;
		i*)   echo $a4 ;;
		s*)   echo $sm ;;
		*)    cat <<- EOF
			> Network Interface : $if
			> MAC Address       : $mac
			----------------------------------------------------------
			> IPv4 CIDR         : $c4
			> IPv4 Address      : $a4
			> IPv4 Netmask      : $sm
			> IPv4 Gateway      : $g4
			----------------------------------------------------------
			> IPv6 CIDR         : ${c6:-N/A}
			> IPv6 Address      : ${a6:-N/A}
			> IPv6 Gateway      : ${g6:-N/A}
			----------------------------------------------------------
			EOF
	esac
}	# end Net.info


OS.networking() {
	# abort if already using classic networking
	[ -e '/run/network/ifstate' ] && return

	# detect: interface, address, gateway, mac address
	local p='/etc/network/interfaces'
	local i=$(Net.info if)

	# assign fixed interface name eth0 based on MAC address
	cat > /etc/udev/rules.d/70-persistent-net.rules <<- EOF
		SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="$(Net.info mac)", NAME="eth0"
		EOF

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
			  address $(Net.info ip4)
			  netmask $(Net.info sm)
			  gateway $(Net.info gw4)
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

