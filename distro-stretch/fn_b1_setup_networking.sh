# ------------------------------------------------------------------------------
# make the ip address static if found to be dynamic, on classic ifupdown
# ------------------------------------------------------------------------------

setup_networking() {
	# abort if NOT using classic networking
	[ -e "/run/network/ifstate" ] || return

	# get some required values
	local IF IP GW=$(cmd ip route get 1.1.1.1)
	IF=$(cmd grep -oP '\s+dev\s+\K\w+' <<< "${GW}")
	IP=$(cmd grep -oP '\s+src\s+\K[\w\.]+' <<< "${GW}")
	GW=$(cmd grep -oP '\s+via\s+\K[\w\.]+' <<< "${GW}")

	cd /etc/network

	# abort if already using static ip address
	cmd grep -q 'inet static' ./interfaces && {
		msg_info "Network already configured with static IP: ${IP}"
		return
	}

	# backup original file
	backup_file ./interfaces

	# setup /etc/network/interfaces file
	cmd cat > ./interfaces <<EOF
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# loopback interface
auto lo
iface lo inet loopback

# ethernet interface
auto ${IF}
iface ${IF} inet static
  address ${IP}/24
  gateway ${GW}
EOF

	# activating the configuration
#	cmd ifdown --force ${IF} lo && cmd ifup -a
	cmd systemctl restart networking

	msg_info "Networking changed to run with static IP: ${IP}"
	msg_alert "Carefully check /etc/network/interfaces before reboot!"
}	# end setup_networking
