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
	# reinstall a debian distro, defaults debian 12
	# $1 - numeric debian version: 10, 11, 12, 13
	local a6 g6 d6 a g d4 v=${1:-12}

	# do checks
	Server.notContainer || return 1

	# start procedure
	Msg.info "Preparing to install Debian $v..."

	# ipv4 CIDR with subnet mask, gateway & dns
	a=$(Net.info cidr)
	g=$(Net.info gw)
	d4=$(cmd awk '{print $1, $2}' <<< "$DNS_v4")
	Msg.info "Detected IPv4 CIDR: $a; gateway $g; DNS $d4"

	# save parameters to use once rebooted
	File.download "https://raw.githubusercontent.com/bohanyang/debi/master/debi.sh" "debi.sh"
	bash ./debi.sh --ethx --version "$v" \
		--ip "$a" --gateway "$g" --dns "$d4" \
		--user root --password 'regulinux' \
		--timezone "$TIME_ZONE" \
		--ssh-port "$SSHD_PORT" \
		--cdn  # https mirror of deb.debian.org

#	# append conditional ipv6 parameters: CIDR, gateway & dns
#	a6=$(Net.info cidr6)
#	if [ -n "$a6" ]; then
#		g6=$(Net.info gw6)
#		d6=$(cmd awk '{print $1, $2}' <<< "$DNS_v6")
#		Msg.info "Detected IPv6 CIDR: $a6; gateway $g6; DNS $d6"
#		cmd cat >> /boot/debian-$ENV_codename/preseed.cfg <<- EOF
#
#			# IPv6 manual config
#			d-i netcfg/disable_dhcpv6 boolean true
#			d-i netcfg/use_autoconfig boolean false
#			d-i netcfg/get_ipaddress_v6 string ${a6%%/*}
#			d-i netcfg/get_gateway_v6 string $g6
#			d-i netcfg/get_prefix_length_v6 string ${a6##*/}
#			d-i netcfg/get_nameservers_v6 string $d6
#			EOF
#	fi

	Msg.warn "Now reboot the server and connect via remote shell from provider"
}	# end Menu.reinstall
