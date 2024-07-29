# ------------------------------------------------------------------------------
# reinstall a debian server, from the server itself
# https://github.com/bohanyang/debi
# ------------------------------------------------------------------------------

Server.notContainer() {
	# returns 1 (error) if the current system is a virtualized container
	# container OpenVZ
	[ -d /proc/vz ] && {
		Msg.warn "No reinstall on OpenVZ containers..."
		return 1
	}
	# container LXC
	[ -d /proc/1/root/.local/share/lxc ] && {
		Msg.warn "No reinstall on LXC containers..."
		return 1
	}
	return 0
}	# end Server.notContainer


Menu.reinstall() {
	# reinstall a debian distro, defaults debian 11
	# $1 - numeric debian version: 10, 11, 12, 13
	local a6 g6 a g v=${1:-11}

	# do checks
	Server.notContainer || return 1

	# start procedure
	Msg.info "Preparing to install Debian $v..."

	# detect ipv4 address with subnet mask & gateway
	a=$(cmd ip -br -4 addr show scope global | cmd awk '{print $3}')
	g=$(cmd ip route get 1.1.1.1 | cmd grep -oP 'via \K\S+')
	Msg.info "Detected IPv4 address: $a; gateway $g"

	# detect ipv6 address with subnet mask & gateway
	a6=$(cmd ip -br -6 addr show scope global | cmd awk '{print $3}')
	g6=$(cmd ip -6 route get 2620:fe::fe | cmd grep -oP 'via \K\S+')
	Msg.info "Detected IPv6 address: $a6; gateway $g6"

	# save parameters to use once rebooted
	File.download "https://raw.githubusercontent.com/bohanyang/debi/master/debi.sh" "debi.sh"
	bash ./debi.sh --version "$v" \
		--ip "$a" --gateway "$g" --dns '1.1.1.1 9.9.9.10' \
		--dns6 '2606:4700:4700::1111 2620:fe::fe' \
		--user root --password 'regulinux' \
		--timezone "$TIME_ZONE" \
		--ssh-port "$SSHD_PORT" \
		--cdn  # https mirror of deb.debian.org
#		--ip6 "$a6" --gateway6 "$g6" \

	Msg.info "Now reboot the server and connect via remote shell from provider"
}	# end Menu.reinstall
