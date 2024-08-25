# ------------------------------------------------------------------------------
# make the ip address static if found to be dynamic, on classic ifupdown
# standardize the networking of sebian 12, using 
# ------------------------------------------------------------------------------

Net.drop.legacy() {
	# removes the legacy way of setup networking: ifupdown & netplan
	# no arguments expected

	# drop ifupdown
	if systemctl is-active -q networking; then
		systemctl stop networking
		systemctl disable networking
		apt-get remove --purge -y ifupdown
		rm -rf /etc/network/interfaces
		Msg.info "Deletion of 'ifupdown' classic networking, completed!"
	fi

	# drop netplan
	if [ "$(ls -A /etc/netplan/ 2>/dev/null)" ]; then
		apt-get purge -y netplan.io
		rm -rf /etc/netplan/*
		Msg.info "Deletion of 'netplan' tool, completed!"
	fi
}	# end Net.drop.legacy


Net.networkd() {
	# setup networking via systemd-networkd on debian 12
	# no arguments expected

	# rename /etc/network/interfaces so it won't be used by systemd-networkd
	if [ -f /etc/network/interfaces ]; then
		mv /etc/network/interfaces   /etc/network/interfaces.save
		mv /etc/network/interfaces.d /etc/network/interfaces.d.save
		Msg.info "Renaming of /etc/network/interfaces, completed!"
	fi

	# enable & start both: networkd & resolved
	systemctl enable systemd-networkd --now
#	cmd systemctl enable systemd-resolved --now
#	ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

	# configure network with IPv4
	cat > /etc/systemd/network/10-static.network <<- EOF
		[Match]
		Name=$(Net.info if)

		[Network]
		Address=$(Net.info cidr4)
		Gateway=$(Net.info gw4)
		DNS=$(awk '{print $1, $2}' <<< "$DNS_v4")
		EOF

	# conditional append IPv6 parameters
	local a="$(Net.info cidr6)" g="$(Net.info gw6)"

	if [ -n "$a" ] && [ -n "$g" ]; then
		cat >> /etc/systemd/network/10-static.network <<- EOF
			Address=$a
			Gateway=$g
			EOF
		if [ -n "$DNS_v6" ]; then
			cat >> /etc/systemd/network/10-static.network <<- EOF
				DNS=$(awk '{print $1, $2}' <<< "$DNS_v6")
				EOF
		fi
	fi

	# restart networkd
	systemctl restart systemd-networkd

	Msg.info "Configuration of network via systemd-networkd, completed!"
}	# end Net.networkd


OS.networking.systemd() {
	# setup networking in debian 12

	# enable & start networkd, if not already active
	systemctl is-active -q "systemd-networkd" || Net.networkd

	# then drop legacy stacks
	Net.drop.legacy

	# debianize /etc/hosts, drop line with ipv4 & add line: 127.0.1.1 hostname
	Net.hostname
}	# end OS.networking
