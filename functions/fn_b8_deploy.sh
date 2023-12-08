# ------------------------------------------------------------------------------
# add a swap file on KVM or DEDI systems that dont have one
# ------------------------------------------------------------------------------

Menu.deploy() {
	# reinstall a debian distro, defaults debian 11
	# $1 - numeric debian version: 10, 11, 12
	local a g v=${1:-11}

	# detect: address, gateway
	a="$(cmd ip -br -4 addr show scope global)"
	a=$(cmd grep -oP '\s+UP\s+\K[\w\.]+' <<< "$a")
	g="$(cmd ip route get 1.1.1.1)"
	g=$(cmd grep -oP '\s+via\s+\K[\w\.]+' <<< "$g")

	Msg.info "Preparing to install Debian $v..."

	# save parameters to use once rebooted
	File.download "https://raw.githubusercontent.com/bohanyang/debi/master/debi.sh" "debi.sh"
	bash debi.sh --version $v \
		--ip $i --gateway $g \
		--dns '1.1.1.1 9.9.9.9 2606:4700:4700::1111 2620:fe::fe' \
		--user root --password bamalama \
		--timezone $TIME_ZONE \
		--ssh-port $SSHD_PORT

	Msg.info "Now reboot the server and connect via remote shell from provider"
}	# end Menu.addswap