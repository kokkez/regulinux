# ------------------------------------------------------------------------------
# disable and remove other networking systems in favor of the classic ifupdown
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
Menu.hostname() {
	# metadata for OS.menu entries
	__section='Standalone utilities'
	__summary="setup the hostname on the current distro"

	# $1 = the fully qualified hostname to set
	# $2 = optional host part of the hostname
	[ -z "$1" ] && {
		Msg.info "it is required a fully qualified hostname!"
		return 1
	}
	perl -pi -e "my (\$f,\$F,\$s,\$S)=('$(hostname -f)','$1','$(hostname -s)','${2:-${1%%.*}}');
		s/\Q\$f\E/\$F/g; s/\Q\$s\E/\$S/g;" "$ENV_dir/settings.conf"
	ENV.config
	Net.hostname
}	# alias fn


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
