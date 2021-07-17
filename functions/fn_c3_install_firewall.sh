# ------------------------------------------------------------------------------
# setup firewall via iptables
# ------------------------------------------------------------------------------

Install.firewall() {
	# setup firewall via iptables
	# $1 - ssh port number, optional
	local p r='ssh' f=~/firewall.sh		# path to the firewall script

	Pkg.installed "iptables" || {
		Msg.error "Seems that iptables was missing"
	}

	p=$( Port.audit ${1:-$SSHD_PORT} )	# strictly numeric port

	# determining default iptables rules
	case $TARGET in
		"ispconfig") r+=' ftp http ssltls mail ispconfig' ;;
		"cloud")     r+=' http' ;;
		"assp")      r+=' http smtp ssltls mysql assp' ;;
	esac;

	# install the firewall script
	rm -rf "$f"
	File.into ~ ssh/firewall.sh
	sed -ri "$f" \
		-e "s|^(SSHPORT=).*|\1'$p'|" \
		-e "s|^(ACCEPTS=).*|\1'$r'|"
	chmod +x "$f"						# make it executable

	# set these rules to load on startup
	p=/etc/network/if-pre-up.d
	rm -rf "$p/iptables"
	File.into "$p" ssh/iptables
	chmod +x "$p/iptables"				# make it executable
}	# end Install.firewall
