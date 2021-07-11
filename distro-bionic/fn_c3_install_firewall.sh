# ------------------------------------------------------------------------------
# setup firewall via iptables
# ------------------------------------------------------------------------------

install_firewall() {
	# setup firewall via iptables
	# $1 port, strictly numeric
	local P F=~/firewall.sh			# path to the firewall script

	Pkg.installed "iptables" || {
		Msg.error "Seems that iptables was missing"
	}

	P=$( Port.audit $1 )			# strictly numeric port

	# determining default iptables rules
	case ${TARGET} in
		"ispconfig") IPT_RULES="ssh ftp http ssltls mail ispconfig" ;;
		"cloud")     IPT_RULES="ssh http" ;;
		"assp")      IPT_RULES="ssh http smtp ssltls mysql assp" ;;
	esac;

	# install the firewall script
	cd ~
	rm -rf ${F}
	File.into . ssh/firewall.sh
	sed -ri ${F} \
		-e "s|^(SSHPORT=).*|\1${P}|" \
		-e "s|^(ACCEPTS=).*|\1\"${IPT_RULES}\"|"
	chmod +x ${F}					# make it executable

	# set these rules to load on startup
	cd /etc/network/if-pre-up.d
	rm -rf iptables
	File.into . ssh/iptables
	chmod +x iptables				# make it executable
}	# end install_firewall
