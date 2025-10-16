# ------------------------------------------------------------------------------
# make the ip address static if found to be dynamic, on classic ifupdown
# ------------------------------------------------------------------------------

Net.info() {
	# return values for the network interface connected to the Internet
	# $1 - desired result: if, mac, ip, gw... also v6: if6, mac6, ip6, gw6
	local if4 ma4 ci4 ip4 sm4 gw4 if6 ma6 ci6 ip6 sm6 gw6
	read _ _ gw4 _ if4 _ < <(ip r s default)
	ma4=$(< /sys/class/net/$if4/address); ma4=${ma4:-00:00:00:00:00:00}
	read _ _ ci4 _ < <(ip -4 -br a s $if4 scope global)
	gw4=${gw4:-0.0.0.0}
	ip4=${ci4%/*}
	sm4=${ci4#*/}		# subnet mask, strip everything until "/"
	sm4=$((0xffffffff << (32 - sm4)))
	sm4=$([ -n "$sm4" ] && { printf '%d.%d.%d.%d\n' \
		$((sm4 >> 24 & 255)) \
		$((sm4 >> 16 & 255)) \
		$((sm4 >> 8 & 255)) \
		$((sm4 & 255))
	})
	# ipv6
	read _ _ _ _ gw6 _ if6 _ ip6 _ < <(ip r g 2001:db8::1 2>/dev/null)
	[ -n "$ip6" ] && {
		ma6=$(< /sys/class/net/$if6/address); ma6=${ma6:-00:00:00:00:00:00}
		read _ _ ci6 _ < <(ip -6 -br a s $if6 scope global)
		sm6=${ci6#*/}	# subnet mask, strip everything until "/"
	}
	case "${1:-}" in
		s*6*)  echo "$sm6" ;;
		s*)    echo "$sm4" ;;
		m*6*)  echo "$ma6" ;;
		m*)    echo "$ma4" ;;
		if*6*) echo "$if6" ;;
		if*)   echo "$if4" ;;
		i*6*)  echo "$ip6" ;;
		i*)    echo "$ip4" ;;
		g*6*)  echo "$gw6" ;;
		g*)    echo "$gw4" ;;
		c*6*)  echo "$ci6" ;;
		c*)    echo "$ci4" ;;
		*) cat <<- EOF
			> $( Dye.fg.cyan.lite Internet Protocol version 4 )
			> Interface   : $( Dye.fg.white $if4 )
			> MAC Address : $( Dye.fg.white $ma4 )
			> CIDR        : $( Dye.fg.white $ci4 )
			> Address     : $( Dye.fg.white $ip4 )
			> Netmask     : $( Dye.fg.white $sm4 )
			> Gateway     : $( Dye.fg.white $gw4 )
			> $( Dye.fg.cyan.lite Internet Protocol version 6 )
			> Interface   : $( Dye.fg.white ${if6:-N/A} )
			> MAC Address : $( Dye.fg.white ${ma6:-N/A} )
			> CIDR        : $( Dye.fg.white ${ci6:-N/A} )
			> Address     : $( Dye.fg.white ${ip6:-N/A} )
			> Netmask     : $( Dye.fg.white ${sm6:-N/A} )
			> Gateway     : $( Dye.fg.white ${gw6:-N/A} )
			EOF
	esac
}	# end Net.info
Menu.inet() {
	# metadata for OS.menu entries
	__section='Standalone utilities'
	__summary="retrieve network-related information from the system"
	Net.info "$@";
}	# alias fn


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
#	systemctl restart networking
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


Net.normalize() {
	# normalize network interface, adding an alias based on MAC address
	# $1 = interface alias name (default eth0)
	# $2 = interface mac (optional, auto-detected if empty)
	local n=${1:-eth0} m=${2:-} if="$(Net.info if)" p=/etc/udev/rules.d/10-network.rules
	# check current interface
	if [ -z "$if" ]; then
		Msg.warn "Interface not found ( $if )"
		return 1
	elif [ ! -d "/sys/class/net/$if" ]; then
		Msg.warn "Interface not present ( $if )"
		return 1
	elif [ "$if" = "$n" ]; then
		return 0    # already done, skip
	fi
	# auto-detect mac if not provided
	[ -z "$m" ] && {
		m="$(Net.info mac)"
		[ -z "$m" ] && {
			Msg.warn "MAC address not found"
			return 1
		}
	}
	# check rule if already exists
	grep -q " NAME=\"$n\"" "$p" 2>/dev/null && return 0
	# write udev rule
	printf 'SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="%s", NAME="%s"\n' "$m" "$n" > "$p"
	# apply immediately, similar to reboot
	udevadm control --reload
    udevadm trigger --subsystem-match=net
	Msg.info "New rule written in udev: $if ($m) -> $n"
}	# end Net.normalize


OS.networking() {
	# setup network stack based on ifupdown
	Net.normalize 'eth0'	# try to normalize eth0

	# ensure ifupdown stack is active; drop others only if needed
	if systemctl is-enabled -q 'networking'; then
		Msg.info "ifupdown stack detected and working, skipping setup"
	else
		Net.dropstack		# drop unwanted stacks
	fi
	Net.ifupdown			# activate classic networking
	Net.hostname			# debianize /etc/hosts
	Msg.warn "Carefully check $(Dye.fg.white /etc/network/interfaces) before reboot!"
}	# end OS.networking
