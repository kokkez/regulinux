# ------------------------------------------------------------------------------
# the OS firewall with all the needed utilities
# ------------------------------------------------------------------------------

Fw.notice() {
	echo -e \
		$( Dye.fg.green 'FireWall' ) \
		$( Dye.fg.green.lite '>>' ) \
		$( Dye.fg.white "$@" )
};	# end Fw.notice

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
	Fw.notice "appending VPN rules"
	Fw.ip4 -t nat -I POSTROUTING 1 -s 10.8.0.0/24 -o venet0 -j MASQUERADE
	Fw.ip4 -I INPUT 1 -i tun0 -j ACCEPT
	Fw.ip4 -I FORWARD 1 -i venet0 -o tun0 -j ACCEPT
	Fw.ip4 -I FORWARD 1 -i tun0 -o venet0 -j ACCEPT
	Fw.ip4 -I INPUT 1 -i venet0 -p udp --dport 1194 -j ACCEPT
};	# end Fw.rule.vpn
Fw.rule.dns() {
	# accept DNS connections
	Fw.notice "appending DNS rules"
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 53 -j ACCEPT
	Fw.ip4 -A INPUT -p udp -m state --state NEW --dport 53 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 53 -j ACCEPT
	Fw.ip6 -A INPUT -p udp -m state --state NEW --dport 53 -j ACCEPT
};	# end Fw.rule.dns
Fw.rule.ftp() {
	# accept FTP connections (+ pure-ftpd passive ports)
	Fw.notice "appending FTP rules"
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 21 -j ACCEPT
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 40010:40910 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 21 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 40010:40910 -j ACCEPT
};	# end Fw.rule.ftp
Fw.rule.ispconfig() {
	# accept HTTP connections
	Fw.notice "appending ISPConfig rules"
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 8080 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 8080 -j ACCEPT
};	# end Fw.rule.ispconfig
Fw.rule.http() {
	# accept HTTP and HTTPS connections (standard ports for websites)
	Fw.notice "appending HTTP and HTTPS rules"
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 80 -j ACCEPT
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 443 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 80 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 443 -j ACCEPT
};	# end Fw.rule.http
Fw.rule.smtp() {
	# accept plain SMTP connections (port 25 for email sending)
	Fw.notice "appending SMTP rules for port 25"
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 25 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 25 -j ACCEPT
};	# end Fw.rule.smtp
Fw.rule.smtps() {
	# accept secured SMTP connections (SSL/TLS ports for email sending)
	Fw.notice "appending SMTP rules for ports with SSL/TLS"
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 465 -j ACCEPT
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 587 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 465 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 587 -j ACCEPT
};	# end Fw.rule.smtps
Fw.rule.mail() {
	# accept MAIL connections (standard ports for email receiving)
	Fw.notice "appending MAIL rules for mail receiving"
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 110 -j ACCEPT
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 143 -j ACCEPT
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 993 -j ACCEPT
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 995 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 110 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 143 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 993 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 995 -j ACCEPT
};	# end Fw.rule.mail
Fw.rule.mysql() {
	# accept MYSQL connections from slaves
	Fw.notice "appending MYSQL rules"
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 3306 -s smtp-e.rete.us,smtp-m.rete.us -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 3306 -s smtp-e.rete.us,smtp-m.rete.us -j ACCEPT
};	# end Fw.rule.mysql
Fw.rule.assp() {
	# accept http/smtp connections for ASSP on special ports
	Fw.notice "appending ASSP rules"
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 22222 -j ACCEPT
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 55555 -j ACCEPT
#	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport 58725 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 22222 -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 55555 -j ACCEPT
#	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport 58725 -j ACCEPT
};	# end Fw.rule.assp
Fw.rule.ssh() {
	# accept SSH connections on special port
	Fw.notice "appending SSH rules (Port: $SSHD_PORT)"
	Fw.ip4 -A INPUT -p tcp -m state --state NEW --dport $SSHD_PORT -j ACCEPT
	Fw.ip6 -A INPUT -p tcp -m state --state NEW --dport $SSHD_PORT -j ACCEPT
};	# end Fw.rule.ssh


Fw.write() {
	# write on files the SSH port number & the firewall allowed keywords
	# $1 - ssh port number
	# $2 - words mapped to Fw.rule.<keyword> functions, as single argument
	Arg.expect "$1" || return

	local a=$( cmd awk '/^\s*Port /{print $2}' /etc/ssh/sshd_config )
	[ "$1" = "$a" ] || {
		# write port in /etc/ssh/sshd_config, then restart daemon
		Fw.notice "writing port '$1', overwriting '$a'"
		sed -ri '/etc/ssh/sshd_config' -e "s|^#?Port.*|Port $1|"
		sed -ri "$ENV_dir/lib.sh" -e "s|^(\s*SSHD_PORT=).*|\1'$1'|"
		cmd systemctl restart ssh
		Fw.notice "restarting SSH completed!"
	}

	a=$( cmd awk -F\' '/^\s*FW_allowed=/{print $2}' ~/lin*/lib.sh )
	[ -z "$2" ] || [ "$2" = "$a" ] || {
		Fw.notice "writing keywords '$2', overwriting '$a'"
		sed -ri "$ENV_dir/lib.sh" -e "s|^(\s*FW_allowed=).*|\1'$2'|"
	}
};	# end Fw.write

Fw.allow() {
	# append keywords to var $FW_allowed in lib.sh
	# $1 - keyword mapped to a Fw.rule.<keyword> function
	Arg.expect "$1" || return

	# unique-ize valid arguments
	local a w
	for w in $FW_allowed $@; do
		! Element.in $w $a && Cmd.usable "^Fw.rule.$w" && a+=" $w"
	done

	# save the new value back into the main lib.sh file
	Fw.notice "Allowing sevices:$a"
	Fw.write "$SSHD_PORT" "${a:1}"

	# load configured rules on system
	Menu.firewall 'start'
};	# end Fw.allow

Fw.configure() {
	# fully configure the firewall, no arguments expected
	Fw.notice "setup basic IPv4 & IPv6 policies"
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

#	Fw.notice "setup IPv6 basic policies"
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

	SSHD_PORT=$( Port.audit $SSHD_PORT )
#	Fw.notice "setup custom IPv4 & IPv6 policies"
	local w
	for w in $FW_allowed; do
#		echo "[Fw.rule.$w]"
		cmd "Fw.rule.$w"
	done

	Fw.notice "setup IPv4 & IPv6 icmp traffic"
	# accepts IPv4 icmp
	Fw.ip4 -A INPUT -p icmp -m limit --limit 1/s --limit-burst 1 -j ACCEPT
	# unlike with IPv4, is not a good idea to block ICMPv6 traffic as IPv6 is much more heavily dependent on it
	Fw.ip6 -A INPUT -p icmpv6 -m limit --limit 1/s --limit-burst 1 -j ACCEPT
#	Fw.ip6 -A INPUT -p tcp -m tcp ! --syn -j ACCEPT

	Fw.notice "logging IPv4 denied traffic"
	# logging IPv4 omly
	Fw.ip4 -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 4

	# drop all other connections
	Fw.ip4 -A INPUT -j DROP
	Fw.ip6 -A INPUT -j DROP

	# error checking before saving
	w="$?"
	(( $w != 0 )) && Fw.notice "an error has occurred ( $w )" && return

	# saving rules for persistent loading at boot
	Fw.ip4save > /etc/iptables.v4.rules
	Fw.ip6save > /etc/iptables.v6.rules
	Fw.notice "rules saving completed!"

	# set port in /etc/ssh/sshd_config, then restart daemon
	Fw.write "$SSHD_PORT"
};	# end Fw.configure

Fw.flush() {
	Fw.notice "flushing current rules from memory and allowing all traffic"
	Fw.ip4 -F
	Fw.ip4 -P OUTPUT ACCEPT
	Fw.ip6 -F
	Fw.ip6 -P OUTPUT ACCEPT
};	# end Fw.flush

Fw.status() {
	Fw.notice "current IPv4 rules"
	Fw.ip4 -nvL
	echo
	Fw.notice "current IPv6 rules"
	Fw.ip6 -nvL
	echo
};	# end Fw.status

Install.firewall() {
	# setup firewall via iptables
	# $1 - ssh port number, optional

	Pkg.installed "iptables" || {
		Msg.error "Seems that iptables was missing"
	}

	local r p=$( Port.audit ${1:-$SSHD_PORT} )	# strictly numeric port

	# determining default iptables rules
	case $TARGET in
		'ispconfig') r='ftp http smtps mail ispconfig' ;;
		'cloud')     r='http' ;;
		'assp')      r='http smtp smtps mysql assp' ;;
	esac

	# write port & keywords values into files
	Fw.write "$p" "ssh $r"

	# make rules persistent, so can load on every boot
	p=/etc/network/if-pre-up.d
	rm -rf "$p/iptables"
	File.into "$p" ssh/iptables
	chmod +x "$p/iptables"				# make it executable

	# newer linux probably want to use iptables-legacy
	Element.in "$ENV_codename" 'buster' && {
		sed -i "$p/iptables" -e "s|s-rest|s-legacy-rest|g"
	}
}	# end Install.firewall

Menu.firewall() {
	case "$1" in
		'start'|'restart')
			Fw.notice "Starting up..."
			Fw.flush
			Fw.configure
			;;
		'stop')
			Fw.notice "Stopping down..."
			Fw.ip4 -F
			Fw.ip6 -F
			exit 0
			;;
		'flush')
			Fw.flush
			;;
		*)
			Fw.notice "$ENV_os"
			Fw.status
			Fw.notice "Usage: os firewall { start | restart | stop | flush | status }"
			;;
	esac
}	# end Menu.firewall
