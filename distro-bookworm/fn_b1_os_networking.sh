# ------------------------------------------------------------------------------
# make the ip address static if found to be dynamic, on classic ifupdown
# ------------------------------------------------------------------------------

Net.info() {
	# return values for the network interface connected to the Internet
	# $1 - optional, desired result: if, mac, cidr, ip, gw, cidr6, ip6, gw6
	local if mac c4 g4 a4 g6 a6 c6 v

	if=$(cmd ip r get 1 | grep -oP 'dev \K\S+')
	mac=$(cmd ip -br l show "$if" | awk '{print $3}')
	c4=$(cmd ip -br -4 a show "$if" | awk '{print $3}')
	g4=$(cmd ip r get 1 | grep -oP 'via \K\S+')
	a4=${c4%%/*}

	# check if IPv6 is enabled
	v=$(cmd ip a s scope global)
	c6=$(grep -oP 'inet6 \K\S+' <<< "$v")
	if [ -n "$c6" ]; then
		g6=$(cmd ip r get :: | grep -oP 'via \K\S+')
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
Menu.net() { Net.info "$@"; }	# alias fn


Net.hostname() {
	# setup hostname in the modern way of assigning it to 127.0.1.1
	local a p

	a="$(Net.info ip4)"
	p=/etc/hosts

	# forcing setup hostname, via systemd
	echo "$HOST_FQDN" > /etc/hostname
	cmd hostnamectl hostname "$HOST_FQDN"

	# always backup =]
	File.backup "$p"

	# remove line with current ipv4
	grep -q "$a" "$p" && {
		sed -i "/$a/d" "$p"
		Msg.info "Deleting line with IPv4 ($a) from $p, completed!"
	}
	# assign hostname to 127.0.1.1 adding line for fqdn + nick hostname
	grep -q "$HOST_FQDN" "$p" || {
		sed -i "/127.0.1.1/d" "$p"
		sed -i "/127.0.0.1/a 127.0.1.1\t$HOST_FQDN $HOST_NICK" "$p"
		Msg.info "Appending hostname line in $p, completed!"
	}
}	# end Net.hostname


Net.ifupdown() {
	# install, activate and configure ifupdown, the classing networking stack
	local g i a4 a6 p

	p=/etc/network/interfaces

	# install required packages
	Pkg.requires ifupdown
	# activating the configuration
	systemctl unmask networking
	systemctl enable networking

	# backup original file
	File.backup "$p"

	# detect v4: interface, gateway, address
	i=$(Net.info if)
	g=$(Net.info gw4)
	a4=$(Net.info cidr4)
	# setup /etc/network/interfaces with v4 data
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
		  gateway $g

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
	# removes the legacy way of setup networking: ifupdown & netplan
	# no arguments expected
	# disable and remove systemd-networkd
	if systemctl is-active -q "systemd-networkd"; then
		local i="systemd-networkd.socket systemd-networkd systemd-networkd-wait-online"
		systemctl stop $i
		systemctl disable $i
		systemctl mask $i
		Msg.info "Deletion of 'systemd-networkd' networking, completed!"
	fi
	# purge netplan
	if [ "$(ls -A /etc/netplan/ 2>/dev/null)" ]; then
		apt -y purge nplan netplan.io
		rm -rf /etc/netplan/*
		Msg.info "Deletion of 'netplan' tool, completed!"
	fi
}	# end Net.dropstack


OS.networking() {
	# setup network stack in debian 12 via ifupdown

	# enable & start classic networking, if not already active
	[ -s '/run/network/ifstate' ] || Net.ifupdown

	# then drop legacy stacks
	Net.dropstack

	# debianize /etc/hosts, drop line with ipv4 & add line: 127.0.1.1 hostname
	Net.hostname

	Msg.warn "Carefully check $(Dye.fg.cyan.lite /etc/network/interfaces) before reboot!"
}	# end OS.networking
