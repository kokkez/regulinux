# ------------------------------------------------------------------------------
# reinstall a debian server, from the server itself
# https://github.com/bohanyang/debi
# ------------------------------------------------------------------------------

Server.isContainer() {
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
}	# end Server.isContainer


Menu.reinstall() {
	# reinstall a debian distro, defaults debian 11
	# $1 - numeric debian version: 10, 11, 12
	local a g v=${1:-11}

	# do checks
	Server.isContainer && return 1

	# start procedure
	Msg.info "Preparing to install Debian $v..."

	# detect ip address with subnet mask
	a="$(cmd ip -br -4 addr show scope global)"
	a=$(cmd awk '{print $3}' <<< "$a")
	Msg.info "Detected IP: $a..."

	# detect gateway
	g="$(cmd ip route get 1.1.1.1)"
	g=$(cmd grep -oP '\s+via\s+\K[\w\.]+' <<< "$g")
	Msg.info "Detected gateway: $g..."

	# save parameters to use once rebooted
	File.download "https://raw.githubusercontent.com/bohanyang/debi/master/debi.sh" "debi.sh"
	bash ./debi.sh --version $v \
		--ip $a --gateway $g \
		--dns '1.1.1.1 9.9.9.10 2606:4700:4700::1111 2620:fe::fe' \
		--user root --password regulinux \
		--timezone $TIME_ZONE \
		--ssh-port $SSHD_PORT \
		--cdn  # https mirror of deb.debian.org

	Msg.info "Now reboot the server and connect via remote shell from provider"
}	# end Menu.reinstall
