#!/bin/bash
### BEGIN INIT INFO
# Provides:          firewall
# Required-Start:
# Required-Stop:
# Should-Start:
# Default-Start:
# Default-Stop:
# Short-Description: Firewall manager
# Description:       Firewall script for VPSes
### END INIT INFO


##	CHECK AND CHANGE OPTION BELOW HERE!
##	############################################################################

# Ports that will be opened
SSHPORT='22'
ACCEPTS='ssh'


##	DO NOT CHANGE ANYTHING BELOW HERE!
##	############################################################################

cmd() {
	# try to run the real command, not an aliased version
	# on missing command, or error, it return silently
	[ -z "$1" ] && return
	local c="$( command -v $1 )"
	shift && [ -n "$c" ] && "$c" "$@"
}
Port.audit() {
	# set port in $1 to be strictly numeric & in range
	local t l p=$( cmd awk '{print int($1)}' <<< ${1:-22} )
	(( p == 22 )) || {
		# limit min & max range
		p=$(( p > 65534 ? 65535 : p < 1025 ? 1024 : p ))
		# exclude net.ipv4.ip_local_port_range (32768-60999)
		t=$( cmd sysctl -e -n net.ipv4.ip_local_port_range )
		l=$( cmd awk '{print int($1)}' <<< $t )
		t=$( cmd awk '{print int($2)}' <<< $t )
		p=$(( p < l ? p : p > t ? p : 64128 ))
	}
	echo $p
}

IP.4()     { cmd iptables-legacy "$@"; }
IP.6()     { cmd ip6tables-legacy "$@"; }
Msg.head() { echo -e "\e[1;32m>> \e[1;37m$* \e[1;32m<<\e[0m"; }
Msg.info() { echo -e "\e[2;32m>> \e[1;37m$*\e[0m"; }

Fw.status() {
	Msg.info "Firewall: current IPv4 rules"
	IP.4 -nvL
	echo
	Msg.info "Firewall: current IPv6 rules"
	IP.6 -nvL
	echo
}
Fw.flush() {
	Msg.info "Firewall: flushing current rules from memory and allowing all traffic"
	IP.4 -F
	IP.4 -P OUTPUT ACCEPT
	IP.6 -F
	IP.6 -P OUTPUT ACCEPT
}
Rule.vpn() {
	Msg.info "Firewall: appending VPN rules"
	# Accept VPN connections from anywhere
	# remember to customize the port before use
	IP.4 -t nat -I POSTROUTING 1 -s 10.8.0.0/24 -o venet0 -j MASQUERADE
	IP.4 -I INPUT 1 -i tun0 -j ACCEPT
	IP.4 -I FORWARD 1 -i venet0 -o tun0 -j ACCEPT
	IP.4 -I FORWARD 1 -i tun0 -o venet0 -j ACCEPT
	IP.4 -I INPUT 1 -i venet0 -p udp --dport 1194 -j ACCEPT
}
Rule.dns() {
	Msg.info "Firewall: appending DNS rules"
	# Accept DNS connections from anywhere
	IP.4 -A INPUT -p tcp -m state --state NEW --dport 53 -j ACCEPT
	IP.4 -A INPUT -p udp -m state --state NEW --dport 53 -j ACCEPT
	IP.6 -A INPUT -p tcp -m state --state NEW --dport 53 -j ACCEPT
	IP.6 -A INPUT -p udp -m state --state NEW --dport 53 -j ACCEPT
}
Rule.ftp() {
	Msg.info "Firewall: appending FTP rules"
	# Accept FTP connections from anywhere (+ pure-ftpd passive ports)
	IP.4 -A INPUT -p tcp -m state --state NEW --dport 21 -j ACCEPT
	IP.4 -A INPUT -p tcp -m state --state NEW --dport 40010:40910 -j ACCEPT
	IP.6 -A INPUT -p tcp -m state --state NEW --dport 21 -j ACCEPT
	IP.6 -A INPUT -p tcp -m state --state NEW --dport 40010:40910 -j ACCEPT
}
Rule.ispconfig() {
	Msg.info "Firewall: appending ISPConfig rules"
	# Accept HTTP connections from anywhere
	IP.4 -A INPUT -p tcp -m state --state NEW --dport 8080 -j ACCEPT
	IP.6 -A INPUT -p tcp -m state --state NEW --dport 8080 -j ACCEPT
}
Rule.http() {
	Msg.info "Firewall: appending HTTP and HTTPS rules"
	# Accept HTTP and HTTPS connections from anywhere (standard ports for websites)
	IP.4 -A INPUT -p tcp -m state --state NEW --dport 80 -j ACCEPT
	IP.4 -A INPUT -p tcp -m state --state NEW --dport 443 -j ACCEPT
	IP.6 -A INPUT -p tcp -m state --state NEW --dport 80 -j ACCEPT
	IP.6 -A INPUT -p tcp -m state --state NEW --dport 443 -j ACCEPT
}
Rule.smtp() {
	Msg.info "Firewall: appending SMTP rules for port 25"
	# Accept SMTP connections from anywhere (port 25 for email sending)
	IP.4 -A INPUT -p tcp -m state --state NEW --dport 25 -j ACCEPT
	IP.6 -A INPUT -p tcp -m state --state NEW --dport 25 -j ACCEPT
}
Rule.ssltls() {
	Msg.info "Firewall: appending SMTP rules with SSL/TLS"
	# Accept SMTP connections from anywhere (standard ports for email sending)
	IP.4 -A INPUT -p tcp -m state --state NEW --dport 465 -j ACCEPT
	IP.4 -A INPUT -p tcp -m state --state NEW --dport 587 -j ACCEPT
	IP.6 -A INPUT -p tcp -m state --state NEW --dport 465 -j ACCEPT
	IP.6 -A INPUT -p tcp -m state --state NEW --dport 587 -j ACCEPT
}
Rule.mail() {
	Msg.info "Firewall: appending MAIL rules for mail receiving"
	# Accept MAIL connections from anywhere (standard ports for email receiving)
	IP.4 -A INPUT -p tcp -m state --state NEW --dport 110 -j ACCEPT
	IP.4 -A INPUT -p tcp -m state --state NEW --dport 143 -j ACCEPT
	IP.4 -A INPUT -p tcp -m state --state NEW --dport 993 -j ACCEPT
	IP.4 -A INPUT -p tcp -m state --state NEW --dport 995 -j ACCEPT
	IP.6 -A INPUT -p tcp -m state --state NEW --dport 110 -j ACCEPT
	IP.6 -A INPUT -p tcp -m state --state NEW --dport 143 -j ACCEPT
	IP.6 -A INPUT -p tcp -m state --state NEW --dport 993 -j ACCEPT
	IP.6 -A INPUT -p tcp -m state --state NEW --dport 995 -j ACCEPT
}
Rule.mysql() {
	Msg.info "Firewall: appending MYSQL rules"
	# Accept MYSQL connections from slaves
	IP.4 -A INPUT -p tcp -m state --state NEW --dport 3306 -s smtp-e.rete.us,smtp-m.rete.us -j ACCEPT
	IP.6 -A INPUT -p tcp -m state --state NEW --dport 3306 -s smtp-e.rete.us,smtp-m.rete.us -j ACCEPT
}
Rule.assp() {
	Msg.info "Firewall: appending ASSP rules"
	# Accept SSH connections on special port
	IP.4 -A INPUT -p tcp -m state --state NEW --dport 22222 -j ACCEPT
	IP.4 -A INPUT -p tcp -m state --state NEW --dport 55555 -j ACCEPT
#	IP.4 -A INPUT -p tcp -m state --state NEW --dport 58725 -j ACCEPT
	IP.6 -A INPUT -p tcp -m state --state NEW --dport 22222 -j ACCEPT
	IP.6 -A INPUT -p tcp -m state --state NEW --dport 55555 -j ACCEPT
#	IP.6 -A INPUT -p tcp -m state --state NEW --dport 58725 -j ACCEPT
}
Rule.ssh() {
	Msg.info "Firewall: appending SSH rules (Port: $SSHPORT)"
	# Accept SSH connections on special port
	IP.4 -A INPUT -p tcp -m state --state NEW --dport $SSHPORT -j ACCEPT
	IP.6 -A INPUT -p tcp -m state --state NEW --dport $SSHPORT -j ACCEPT
}
Ssh.restart() {
	# set port in /etc/ssh/sshd_config, then restart daemon
	sed -ri '/etc/ssh/sshd_config' \
		-e "s|^Port.*|Port $SSHPORT|"
	sed -ri "${BASH_SOURCE[0]}" \
		-e"s|^SSHPORT=.*|SSHPORT='$SSHPORT'|"
	cmd systemctl restart ssh
	Msg.info "Restarting SSH completed!"
}
Fw.configure() {
	SSHPORT=$( Port.audit $SSHPORT )

	Msg.info "Firewall: setup basic IPv4 & IPv6 policies"
	IP.4 -P INPUT DROP
	IP.4 -P FORWARD DROP
	# Accepts all established inbound connections
	IP.4 -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	# Accept all loopback (lo0) traffic and drop all traffic to 127/8 that not use lo0
	IP.4 -A INPUT -i lo -j ACCEPT
	IP.4 -A INPUT ! -i lo -d 127.0.0.0/8 -j REJECT
	# protect from some commons attack
	# drop incoming NEW tcp connections that are not SYN packets
	IP.4 -A INPUT -m state --state NEW -p tcp ! --syn -j DROP
	# drop incoming packets with fragments, to inhibit Linux server panic
	IP.4 -A INPUT -f -j DROP
	# drop incoming malformed XMAS & NULL packets
	IP.4 -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
	IP.4 -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

#	Msg.info "Firewall: setup IPv6 basic policies"
	# these appear before any other rules
	IP.6 -A INPUT -m rt --rt-type 0 --rt-segsleft 0 -j DROP
	IP.6 -A FORWARD -m rt --rt-type 0 --rt-segsleft 0 -j DROP
	IP.6 -A OUTPUT -m rt --rt-type 0 --rt-segsleft 0 -j DROP
	# Accepts all established inbound connections
	IP.6 -P INPUT DROP
	IP.6 -P FORWARD DROP
	# Accepts all established inbound connections
	IP.6 -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	# Accept all traffic from/to the local interface.
	IP.6 -A INPUT -i lo -j ACCEPT

#	Msg.info "Firewall: setup custom IPv4 & IPv6 policies"
	local w
	for w in $ACCEPTS ; do
#		echo "[Rule.$w]"
		cmd "Rule.$w"
	done

	Msg.info "Firewall: setup IPv4 & IPv6 icmp traffic"
	# Accepts IPv4 icmp
	IP.4 -A INPUT -p icmp -m limit --limit 1/s --limit-burst 1 -j ACCEPT
	# Unlike with IPv4, is not a good idea to block ICMPv6 traffic as IPv6 is much more heavily dependent on it.
	IP.6 -A INPUT -p icmpv6 -m limit --limit 1/s --limit-burst 1 -j ACCEPT
#	IP.6 -A INPUT -p tcp -m tcp ! --syn -j ACCEPT

	Msg.info "Firewall: logging IPv4 denied traffic"
	# Logging IPv4 omly
	IP.4 -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 4

	# Drop all other connections
	IP.4 -A INPUT -j DROP
	IP.6 -A INPUT -j DROP

	# save in files
	[ $? -eq 0 ] && {
		cmd iptables-legacy-save > /etc/iptables.v4.rules
		cmd ip6tables-legacy-save > /etc/iptables.v6.rules
		Msg.info "Firewall: rules saving completed!"
		Ssh.restart
	} || {
		Msg.info "Firewall: an error has occurred ( $? )"
	}
}


##	PROGRAM
##	############################################################################

case "$1" in
	start|restart)
		Msg.head "Starting firewall..."
		Fw.flush
		Fw.configure
		;;
	stop)
		Msg.head "Stopping firewall..."
		IP.4 -F
		IP.6 -F
		exit 0
		;;
	flush)
		Fw.flush
		;;
	*)
		Msg.head "Firewall status..."
		Fw.status
		Msg.head "Usage: $0 { start | restart | stop | status | flush }"
		;;
esac

