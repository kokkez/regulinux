# ------------------------------------------------------------------------------
# make the ip address static if found to be dynamic, on classic ifupdown
# standardize the networking of sebian 12, using 
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


Net.hostname() {
	# setup hostname in the modern way of assigning it to 127.0.1.1
	local a="$(Net.info ip)" p=/etc/hosts

	# force setup hostname, via systemd
	echo "$HOST_FQDN" > /etc/hostname
	cmd hostnamectl hostname "$HOST_FQDN"

	# always backup =]
	File.backup "$p"

	# remove line with current ipv4
	grep -q "$a" "$p" && {
		cmd sed -i "/$a/d" "$p"
		Msg.info "Deleting line with current IPv4 ($a) from $p, completed!"
	}

	# assign hostname to 127.0.1.1 adding line for fqdn + nick hostname
	grep -q '127.0.1.1' "$p" || {
		cmd sed -i "/127.0.0.1/a 127.0.1.1\t$HOST_FQDN $HOST_NICK" "$p"
		Msg.info "Appending hostname line in $p, completed!"
	}
}	# end Net.hostname


Net.drop.legacy() {
	# removes the legacy way of setup networking: ifupdown & netplan
	# no arguments expected

	# drop ifupdown
	if cmd systemctl is-active -q networking; then
		cmd systemctl stop networking
		cmd systemctl disable networking
		cmd apt-get remove --purge -y ifupdown
		cmd rm -rf /etc/network/interfaces
		Msg.info "Deletion of 'ifupdown' classic networking, completed!"
	fi

	# drop netplan
	if [ "$(ls -A /etc/netplan/ 2>/dev/null)" ]; then
		cmd apt-get purge -y netplan.io
		cmd rm -rf /etc/netplan/*
		Msg.info "Deletion of 'netplan' tool, completed!"
	fi
}	# end Net.drop.legacy


Net.networkd() {
	# setup networking via systemd-networkd on debian 12
	# no arguments expected

	# rename /etc/network/interfaces so it won't be used by systemd-networkd
	if [ -f /etc/network/interfaces ]; then
		cmd mv /etc/network/interfaces   /etc/network/interfaces.save
		cmd mv /etc/network/interfaces.d /etc/network/interfaces.d.save
		Msg.info "Renaming of /etc/network/interfaces, completed!"
	fi

	# enable & start both: networkd & resolved
	cmd systemctl enable systemd-networkd --now
#	cmd systemctl enable systemd-resolved --now
#	ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

	# configure network with IPv4
	cmd cat > /etc/systemd/network/10-static.network <<- EOF
		[Match]
		Name=$(Net.info if)

		[Network]
		Address=$(Net.info ip4)
		Gateway=$(Net.info gw4)
		DNS=$(cmd awk '{print $1, $2}' <<< "$DNS_v4")
		EOF

	# conditional append IPv6 parameters
	local a="$(Net.info ip6)" g="$(Net.info gw6)"

	if [ -n "$a" ] && [ -n "$g" ]; then
		cmd cat >> /etc/systemd/network/10-static.network <<- EOF
			Address=$a
			Gateway=$g
			EOF
		if [ -n "$DNS_v6" ]; then
			cmd cat >> /etc/systemd/network/10-static.network <<- EOF
				DNS=$(cmd awk '{print $1, $2}' <<< "$DNS_v6")
				EOF
		fi
	fi

	# restart networkd
	cmd systemctl restart systemd-networkd

	Msg.info "Configuration of network via systemd-networkd, completed!"
}	# end Net.networkd


OS.networking() {
	# setup networking in debian 12

	# enable & start networkd, if not already active
	cmd systemctl is-active -q "systemd-networkd" || Net.networkd

	# then drop legacy stacks
	Net.drop.legacy

	# debianize /etc/hosts, drop line with ipv4 & add line: 127.0.1.1 hostname
	Net.hostname
}	# end OS.networking
