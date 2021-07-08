# ------------------------------------------------------------------------------
# disable and remove netplan networking system in favor of the classic ifupdown
# ------------------------------------------------------------------------------

setup_networking() {
	# abort if already using classic networking
	[ -e "/run/network/ifstate" ] && return

	# get some required values
	local IF IP GW=$(cmd ip route get 1.1.1.1)
	IF=$(cmd grep -oP '\s+dev\s+\K\w+' <<< "${GW}")
	IP=$(cmd grep -oP '\s+src\s+\K[\w\.]+' <<< "${GW}")
	GW=$(cmd grep -oP '\s+via\s+\K[\w\.]+' <<< "${GW}")

	# install required packages
	pkg_require ifupdown

	# setup /etc/network/interfaces file
	cd /etc/network
	cmd grep -q 'auto lo' ./interfaces || {
		cmd cat >> ./interfaces <<EOF
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
	}

	# activating the configuration
	cmd ifdown --force ${IF} lo && cmd ifup -a
	cmd systemctl unmask networking
	cmd systemctl enable networking
	cmd systemctl restart networking

	# disable and remove the unwanted services
	IF="systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online"
	cmd systemctl stop ${IF}
	cmd systemctl disable ${IF}
	cmd systemctl mask ${IF}
	cmd apt -y purge nplan netplan.io

	msg_info "Configuration of netplan was fully disabled"
	msg_alert "Carefully check /etc/network/interfaces before reboot!"
}	# end setup_networking

