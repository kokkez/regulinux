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
	local a6 g6 d6 a g d4 v=${1:-11}

	# do checks
	Server.notContainer || return 1

	# start procedure
	Msg.info "Preparing to install Debian $v..."

	# ipv4 CIDR with subnet mask, gateway & dns
	a=$(cmd ip -br -4 addr show scope global | cmd awk '{print $3}')
	g=$(cmd ip route get 1.1.1.1 | cmd grep -oP 'via \K\S+')
	d4=$(cmd awk '{print $1, $2}' <<< "$DNS_v4")
	Msg.info "Detected IPv4 address: $a; gateway $g"

	# ipv6 CIDR with subnet mask, gateway & dns
	a6=$(cmd ip -br -6 addr show scope global | cmd awk '{print $3}')
	g6=$(cmd ip -6 route get 2620:fe::fe | cmd grep -oP 'via \K\S+')
	d6=$(cmd awk '{print $1, $2}' <<< "$DNS_v6")
	Msg.info "Detected IPv6 address: $a6; gateway $g6"

	# save parameters to use once rebooted
	File.download "https://raw.githubusercontent.com/bohanyang/debi/master/debi.sh" "debi.sh"
	bash ./debi.sh --ethx --version "$v" \
		--ip "$a" --gateway "$g" --dns "$d4" --dns6 "$d6" \
		--user root --password 'regulinux' \
		--timezone "$TIME_ZONE" \
		--ssh-port "$SSHD_PORT" \
		--cdn  # https mirror of deb.debian.org

	Msg.info "Now reboot the server and connect via remote shell from provider"
}	# end Menu.reinstall
