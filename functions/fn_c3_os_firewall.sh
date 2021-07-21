# ------------------------------------------------------------------------------
# the OS firewall with all the needed utilities
# ------------------------------------------------------------------------------

Fw.notice() {
	Dye.as 1 37 $( Dye.as 2 32 '>> ' ) "$@"
}


# distinguish classic vs legacy version of the iptables commands
Element.in "$ENV_codename" 'buster' && {
	# legacy version of the commands
	Fw.ip4()     { cmd iptables-legacy "$@"; }
	Fw.ip6()     { cmd ip6tables-legacy "$@"; }
	Fw.ip4save() { cmd iptables-legacy-save "$@"; }
	Fw.ip6save() { cmd ip6tables-legacy-save "$@"; }
} || {
	# classic version of the commands
	Fw.ip4()     { cmd iptables "$@"; }
	Fw.ip6()     { cmd ip6tables "$@"; }
	Fw.ip4save() { cmd iptables-save "$@"; }
	Fw.ip6save() { cmd ip6tables-save "$@"; }
}


Fw.rule.vpn() {
	# accept VPN connections
	# remember to customize the port before use
	Fw.notice "Firewall: appending VPN rules"
	Fw.ip4 -t nat -I POSTROUTING 1 -s 10.8.0.0/24 -o venet0 -j MASQUERADE
	Fw.ip4 -I INPUT 1 -i tun0 -j ACCEPT
	Fw.ip4 -I FORWARD 1 -i venet0 -o tun0 -j ACCEPT
	Fw.ip4 -I FORWARD 1 -i tun0 -o venet0 -j ACCEPT
	Fw.ip4 -I INPUT 1 -i venet0 -p udp --dport 1194 -j ACCEPT
}
Fw.rule.dns() {
	# accept DNS connections
	Fw.notice "Firewall: appending DNS rules"
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 53 -j ACCEPT
	Fw.ip4 -A INPUT -p udp -m state --state NEW --dport 53 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 53 -j ACCEPT
	Fw.ip6 -A INPUT -p udp -m state --state NEW --dport 53 -j ACCEPT
}
Fw.rule.ftp() {
	# accept FTP connections (+ pure-ftpd passive ports)
	Fw.notice "Firewall: appending FTP rules"
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 21 -j ACCEPT
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 40010:40910 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 21 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 40010:40910 -j ACCEPT
}
Fw.rule.ispconfig() {
	# accept HTTP connections
	Fw.notice "Firewall: appending ISPConfig rules"
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 8080 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 8080 -j ACCEPT
}
Fw.rule.http() {
	# accept HTTP and HTTPS connections (standard ports for websites)
	Fw.notice "Firewall: appending HTTP and HTTPS rules"
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 80 -j ACCEPT
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 443 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 80 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 443 -j ACCEPT
}
Fw.rule.smtp() {
	# accept plain SMTP connections (port 25 for email sending)
	Fw.notice "Firewall: appending SMTP rules for port 25"
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 25 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 25 -j ACCEPT
}
Fw.rule.ssltls() {
	# accept secured SMTP connections (SSL/TLS ports for email sending)
	Fw.notice "Firewall: appending SMTP rules with SSL/TLS"
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 465 -j ACCEPT
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 587 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 465 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 587 -j ACCEPT
}
Fw.rule.mail() {
	# accept MAIL connections (standard ports for email receiving)
	Fw.notice "Firewall: appending MAIL rules for mail receiving"
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 110 -j ACCEPT
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 143 -j ACCEPT
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 993 -j ACCEPT
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 995 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 110 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 143 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 993 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 995 -j ACCEPT
}
Fw.rule.mysql() {
	# accept MYSQL connections from slaves
	Fw.notice "Firewall: appending MYSQL rules"
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 3306 -s smtp-e.rete.us,smtp-m.rete.us -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 3306 -s smtp-e.rete.us,smtp-m.rete.us -j ACCEPT
}
Fw.rule.assp() {
	# accept http/smtp connections for ASSP on special ports
	Fw.notice "Firewall: appending ASSP rules"
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 22222 -j ACCEPT
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 55555 -j ACCEPT
#	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 58725 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 22222 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 55555 -j ACCEPT
#	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 58725 -j ACCEPT
}
Fw.rule.ssh() {
	# accept SSH connections on special port
	Fw.notice "Firewall: appending SSH rules (Port: $SSHD_PORT)"
	local p=$( Port.audit $SSHD_PORT )
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport $p -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport $p -j ACCEPT
}


Fw.save() {
	(( $1 != 0 )) && {
		Fw.notice "Firewall: an error has occurred ( $1 )"
		return
	}

	# save rules for persistent loading at boot
	Fw.ip4save > /etc/iptables.v4.rules
	Fw.ip6save > /etc/iptables.v6.rules
	Fw.notice "Firewall: rules saving completed!"

	# set port in /etc/ssh/sshd_config, then restart daemon
	sed -ri '/etc/ssh/sshd_config' \
		-e "s|^#?Port.*|Port $SSHD_PORT|"
	sed -ri "$ENV_dir/lib.sh" \
		-e"s|^(\s*SSHD_PORT=).*|\1'$SSHD_PORT'|"
	cmd systemctl restart ssh
	Msg.info "Restarting SSH completed!"
}

Fw.configure() {
	# fully configure the firewall, no arguments expected
	Fw.notice "Firewall: setup basic IPv4 & IPv6 policies"
	Fw.ip4 -P INPUT DROP
	Fw.ip4 -P FORWARD DROP
	# accepts all established inbound connections
	Fw.ip4 -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	# accept all loopback (lo0) traffic and drop all traffic to 127/8 that not use lo0
	Fw.ip4 -A INPUT -i lo -j ACCEPT
	Fw.ip4 -A INPUT ! -i lo -d 127.0.0.0/8 -j REJECT
	# protect from some commons attack
	# drop incoming NEW tcp connections that are not SYN packets
	Fw.ip4 -A INPUT -m state --state NEW -p tcp ! --syn -j DROP
	# drop incoming packets with fragments, to inhibit Linux server panic
	Fw.ip4 -A INPUT -f -j DROP
	# drop incoming malformed XMAS & NULL packets
	Fw.ip4 -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
	Fw.ip4 -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

#	Fw.notice "Firewall: setup IPv6 basic policies"
	# these appear before any other rules
	Fw.ip6 -A INPUT -m rt --rt-type 0 --rt-segsleft 0 -j DROP
	Fw.ip6 -A FORWARD -m rt --rt-type 0 --rt-segsleft 0 -j DROP
	Fw.ip6 -A OUTPUT -m rt --rt-type 0 --rt-segsleft 0 -j DROP
	# accepts all established inbound connections
	Fw.ip6 -P INPUT DROP
	Fw.ip6 -P FORWARD DROP
	# accepts all established inbound connections
	Fw.ip6 -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	# accept all traffic from/to the local interface.
	Fw.ip6 -A INPUT -i lo -j ACCEPT

#	Fw.notice "Firewall: setup custom IPv4 & IPv6 policies"
	local w
	for w in $ACCEPTS ; do
#		echo "[Fw.rule.$w]"
		cmd "Fw.rule.$w"
	done

	Fw.notice "Firewall: setup IPv4 & IPv6 icmp traffic"
	# accepts IPv4 icmp
	Fw.ip4 -A INPUT -p icmp -m limit --limit 1/s --limit-burst 1 -j ACCEPT
	# unlike with IPv4, is not a good idea to block ICMPv6 traffic as IPv6 is much more heavily dependent on it
	Fw.ip6 -A INPUT -p icmpv6 -m limit --limit 1/s --limit-burst 1 -j ACCEPT
#	Fw.ip6 -A INPUT -p tcp -m tcp ! --syn -j ACCEPT

	Fw.notice "Firewall: logging IPv4 denied traffic"
	# logging IPv4 omly
	Fw.ip4 -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 4

	# drop all other connections
	Fw.ip4 -A INPUT -j DROP
	Fw.ip6 -A INPUT -j DROP

	# saving rules for persistent loading at boot, then setup ssh
	Fw.save "$?"
}

Fw.flush() {
	Fw.notice "Firewall: flushing current rules from memory and allowing all traffic"
	Fw.ip4 -F
	Fw.ip4 -P OUTPUT ACCEPT
	Fw.ip6 -F
	Fw.ip6 -P OUTPUT ACCEPT
}

Fw.status() {
	Fw.notice "Firewall: current IPv4 rules"
	Fw.ip4 -nvL
	echo
	Fw.notice "Firewall: current IPv6 rules"
	Fw.ip6 -nvL
	echo
}

Menu.firewall() {
	case "$1" in
		'start'|'restart')
			Fw.notice "Starting firewall..."
			Fw.flush
			Fw.configure
			;;
		'stop')
			Fw.notice "Stopping firewall..."
			Fw.ip4 -F
			Fw.ip6 -F
			exit 0
			;;
		'flush')
			Fw.flush
			;;
		*)
			Fw.notice "Firewall status..."
			Fw.status
			Fw.notice "Usage: $0 { start | restart | stop | status | flush }"
			;;
	esac
}	# end Menu.firewall


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
