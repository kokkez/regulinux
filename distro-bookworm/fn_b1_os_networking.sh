# ------------------------------------------------------------------------------
# make the ip address static if found to be dynamic, on classic ifupdown
# ------------------------------------------------------------------------------

field.after() {
	# return the word after a marker in a line/multiline
	# $1 = marker to search
	# $2 = default on no result
	local l w p d="${2:-}"
	while read -r l; do for w in $l; do
		[ "$p" = "$1" ] && { echo "${w:-$d}" ; return; }
		p=$w
	done; done
	# if marker not found or no word after it, fallback to default
	[ -n "$2" ] && echo "$d"
};	# end of field.after


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
			> Network Interface : $( Dye.fg.white $if )
			> MAC Address       : $( Dye.fg.white $mac )
			----------------------------------------------------------
			> IPv4 CIDR         : $( Dye.fg.white $c4 )
			> IPv4 Address      : $( Dye.fg.white $a4 )
			> IPv4 Netmask      : $( Dye.fg.white $sm )
			> IPv4 Gateway      : $( Dye.fg.white $g4 )
			----------------------------------------------------------
			> IPv6 CIDR         : $( Dye.fg.white ${c6:-N/A} )
			> IPv6 Address      : $( Dye.fg.white ${a6:-N/A} )
			> IPv6 Gateway      : $( Dye.fg.white ${g6:-N/A} )
			----------------------------------------------------------
			EOF
	esac
}	# end Net.info
Menu.inet() {
	# metadata for OS.menu entries
	__section='Standalone utilities'
	__summary="retrieve network-related information from the system"
	Net.info "$@";
}	# alias fn


Net.interface() {
	# normalize network interface, adding an alias to eth0 based on MAC
	local p m if="$(Net.info if)"

	# required checks
	if [ -z "$if" ]; then
		Msg.warn "Interface not found ( $if )"
		return 1
	elif [ ! -d "/sys/class/net/$if" ]; then
		Msg.warn "Interface not present ( $if )"
		return 1
	elif [ "$if" = "eth0" ]; then
		return 0    # already eth0, skip
	fi

	# write udev rule
	p=/etc/udev/rules.d/10-network.rules
	grep -q 'NAME="eth0"' "$p" 2>/dev/null && return 0    # already wrote

	m="$(Net.info mac)"
	printf 'SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="%s", NAME="eth0"\n' "$m" > "$p"
	Msg.info "New rule written in udev: $if ($m) -> eth0"
}	# end Net.interface


Net.hostname() {
	# debianize /etc/hosts, drop line with ipv4 & add line: 127.0.1.1 hostname
	local a p

	# forcing setup hostname, via systemd
	echo "$HOST_FQDN" > /etc/hostname
	hostnamectl set-hostname "$HOST_FQDN"

	# always backup =]
	p=/etc/hosts
	File.backup "$p"

	# remove line with current ipv4
	a="$(Net.info ip4)"
	grep -q "$a" "$p" && {
		sed -i "/$a/d" "$p"
		Msg.info "Removed line with IPv4 ($a) from $p, completed!"
	}
	# assign hostname to 127.0.1.1 adding line for fqdn + nick hostname
	grep -q "$HOST_FQDN" "$p" || {
		sed -i "/127.0.1.1/d" "$p"
		sed -i "/127.0.0.1/a 127.0.1.1\t$HOST_FQDN $HOST_NICK" "$p"
		Msg.info "Appended 127.0.1.1 with $HOST_FQDN $HOST_NICK in $p, completed!"
	}
}	# end Net.hostname


Net.ifupdown() {
	# install, activate and configure ifupdown, the classing networking stack
	local g i a4 a6 p

	# install required packages
	Pkg.requires ifupdown
	# activating the configuration
	systemctl unmask networking
	systemctl enable networking

	# backup original file
	p=/etc/network/interfaces
	File.backup "$p"

	# setup /etc/network/interfaces with v4 data
	i=$(Net.info if)
	a4=$(Net.info ip4)
	cat > "$p" <<- EOF
		# This file describes the network interfaces available on your system
		# and how to activate them. For more information, see interfaces(5).

		# loopback interface
		auto lo
		iface lo inet loopback

		# ethernet interface v4
		auto $i
		iface $i inet static
		  address $a4
		  netmask $(Net.info sm4)
		  gateway $(Net.info gw4)

		EOF
	# conditional append v6 data
	g=$(Net.info gw6)
	a6=$(Net.info cidr6)
	if [ -n "$a6" ] && [ -n "$g" ]; then
		cat >> "$p" <<- EOF
			iface $i inet6 static
			  address $a6
			  gateway $g

			EOF
	fi
	# restart networking
#	cmd ifdown --force $i lo && cmd ifup -a
	systemctl restart networking

	Msg.info "Networking changed to run with static IP: $a4"
}	# end Net.ifupdown


Net.dropstack() {
	# drop network stacks: systemd-networkd, netplan
	# no arguments expected

	# nuke systemd-networkd
	if systemctl is-active -q 'systemd-networkd'; then
		local i="systemd-networkd.socket systemd-networkd systemd-networkd-wait-online"
		systemctl stop $i
		systemctl disable $i
		systemctl mask $i
		Msg.info "Deletion of 'systemd-networkd' stack, completed!"
	fi

	# purge netplan
	if [ "$(ls -A /etc/netplan/ 2>/dev/null)" ]; then
		apt -y purge nplan netplan.io
		rm -rf /etc/netplan/*
		Msg.info "Deletion of 'netplan' stack, completed!"
	fi
}	# end Net.dropstack


OS.networking() {
	# setup network stack in debian 12, based on ifupdown

	# ensure ifupdown stack is active; drop others only if needed
	if systemctl is-enabled -q 'networking'; then
		Msg.info "ifupdown stack detected and working, skipping setup"
	else
		# then drop legacy stacks
		Net.dropstack

		# activate classic networking
		Net.ifupdown

		Msg.warn "Carefully check $(Dye.fg.cyan.lite /etc/network/interfaces) before reboot!"
	fi

	Net.interface	# try to normalize eth0
	Net.hostname	# debianize /etc/hosts
}	# end OS.networking
