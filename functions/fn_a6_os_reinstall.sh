# ------------------------------------------------------------------------------
# reinstall a debian server, from the server itself
# https://github.com/bohanyang/debi
# https://github.com/bin456789/reinstall
# ------------------------------------------------------------------------------

Via.debi() {
	# reinstall a debian distro, defaults debian 12
	# $1 = distro: debian only
	# $2 = numeric debian version: 10, 11, 12, 13
	local a g d4 v=${2:-12}

	# start procedure
	Msg.info "Preparing to install $1 $v..."

	# ipv4 CIDR with subnet mask, gateway & dns
	a=$(Net.info cidr)
	g=$(Net.info gw)
	d4=$(cmd awk '{print $1, $2}' <<< "$DNS_v4")
	Msg.info "Detected IPv4 CIDR: $a; gateway $g; DNS $d4"

	# download and execute in bash
	File.download \
		"https://raw.githubusercontent.com/bohanyang/debi/master/debi.sh" \
		"debi.sh"
	bash ./debi.sh --version "$v" \
		--ethx --ip "$a" --gateway "$g" --dns "$d4" \
		--ssh-port "$SSHD_PORT" \
		--user root --password 'regulinux' \
		--timezone "$TIME_ZONE" \
		--network-console \
		--cdn  # https mirror of deb.debian.org

	Msg.warn "Now reboot the server and connect via remote shell from provider"
}	# end Via.debi


Via.reinstall() {
	# reinstall a generic distro, mainly ubuntu, default 22.04
	# $1 = distro: debian or ubuntu
	# $2 = version
	local d=${1,,} v=${2:-22.04}
	Msg.info "Preparing to install $1 $v..."

	# download and execute in bash
	File.download \
		"https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh" \
		"reinstall.sh"
	bash ./reinstall.sh $d $v --minimal \
		--password 'regulinux' \
		--ssh-port "$SSHD_PORT"

	Msg.warn "Now reboot the server and connect via remote shell from provider"
}	# end Via.reinstall


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
	# metadata for OS.menu entries
	__exclude='[[ $(systemd-detect-virt) != kvm ]]'
	__section='One time actions'
	__summary="reinstall OS on VM (not containers), default $(Dye.fg.white Debian 12)"

	# do checks, with message
	Server.notContainer || return 1
	Pkg.requires wget ca-certificates

	# reinstall a debian like distro, defaults debian 12
	case $1 in
		d8)   Via.reinstall Debian 8 ;;
		d9)   Via.reinstall Debian 9 ;;
		d10)  Via.debi Debian 10 ;;
		d11)  Via.debi Debian 11 ;;
		d13)  Via.debi Debian 13 ;;
		u16)  Via.reinstall Ubuntu 16.04 ;;
		u18)  Via.reinstall Ubuntu 18.04 ;;
		u20)  Via.reinstall Ubuntu 20.04 ;;
		u22)  Via.reinstall Ubuntu 22.04 ;;
		*)    Via.debi Debian 12 ;;
	esac;
}	# end Menu.reinstall
