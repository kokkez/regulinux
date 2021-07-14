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
SSHPORT=22
ACCEPTS="ssh"


##	DO NOT CHANGE ANYTHING BELOW HERE!
##	############################################################################
# paths to iptables (IPv4 only) & ip6tables (IPv6 only)
v4=$(command -v iptables)
v6=$(command -v ip6tables)

message() {
	echo -e "\e[1;32m>> \e[1;37m$* \e[1;32m<<\e[0m"
}
notice() {
	echo -e "\e[2;32m>> \e[1;37m$*\e[0m"
}
cmd() {
	# try to run the real command, not an aliased version
	# on missing command, or error, it return silently
	[ -z "$1" ] && return 0
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
Fw.status() {
	notice "Firewall: current IPv4 rules"
	$v4 -nvL
	echo
	notice "Firewall: current IPv6 rules"
	$v6 -nvL
	echo
}
Fw.flush() {
	notice "Firewall: flushing current rules from memory and allowing all traffic"
	$v4 -F
	$v4 -P OUTPUT ACCEPT
	$v6 -F
	$v6 -P OUTPUT ACCEPT
}
Rule.vpn() {
	notice "Firewall: arrange VPN rules"
	# Accept VPN connections from anywhere
	# remember to customize the port before use
	$v4 -t nat -I POSTROUTING 1 -s 10.8.0.0/24 -o venet0 -j MASQUERADE
	$v4 -I INPUT 1 -i tun0 -j ACCEPT
	$v4 -I FORWARD 1 -i venet0 -o tun0 -j ACCEPT
	$v4 -I FORWARD 1 -i tun0 -o venet0 -j ACCEPT
	$v4 -I INPUT 1 -i venet0 -p udp --dport 1194 -j ACCEPT
}
Rule.dns() {
	notice "Firewall: arrange DNS rules"
	# Accept DNS connections from anywhere
	$v4 -A INPUT -p tcp -m state --state NEW --dport 53 -j ACCEPT
	$v4 -A INPUT -p udp -m state --state NEW --dport 53 -j ACCEPT
	$v6 -A INPUT -p tcp -m state --state NEW --dport 53 -j ACCEPT
	$v6 -A INPUT -p udp -m state --state NEW --dport 53 -j ACCEPT
}
Rule.ftp() {
	notice "Firewall: arrange FTP rules"
	# Accept FTP connections from anywhere (+ pure-ftpd passive ports)
	$v4 -A INPUT -p tcp -m state --state NEW --dport 21 -j ACCEPT
	$v4 -A INPUT -p tcp -m state --state NEW --dport 40010:40910 -j ACCEPT
	$v6 -A INPUT -p tcp -m state --state NEW --dport 21 -j ACCEPT
	$v6 -A INPUT -p tcp -m state --state NEW --dport 40010:40910 -j ACCEPT
}
Rule.ispconfig() {
	notice "Firewall: arrange ISPConfig rules"
	# Accept HTTP connections from anywhere
	$v4 -A INPUT -p tcp -m state --state NEW --dport 8080 -j ACCEPT
	$v6 -A INPUT -p tcp -m state --state NEW --dport 8080 -j ACCEPT
}
Rule.http() {
	notice "Firewall: arrange HTTP and HTTPS rules"
	# Accept HTTP and HTTPS connections from anywhere (standard ports for websites)
	$v4 -A INPUT -p tcp -m state --state NEW --dport 80 -j ACCEPT
	$v4 -A INPUT -p tcp -m state --state NEW --dport 443 -j ACCEPT
	$v6 -A INPUT -p tcp -m state --state NEW --dport 80 -j ACCEPT
	$v6 -A INPUT -p tcp -m state --state NEW --dport 443 -j ACCEPT
}
Rule.smtp() {
	notice "Firewall: arrange SMTP rules for port 25"
	# Accept SMTP connections from anywhere (port 25 for email sending)
	$v4 -A INPUT -p tcp -m state --state NEW --dport 25 -j ACCEPT
	$v6 -A INPUT -p tcp -m state --state NEW --dport 25 -j ACCEPT
}
Rule.ssltls() {
	notice "Firewall: arrange SMTP rules with SSL/TLS"
	# Accept SMTP connections from anywhere (standard ports for email sending)
	$v4 -A INPUT -p tcp -m state --state NEW --dport 465 -j ACCEPT
	$v4 -A INPUT -p tcp -m state --state NEW --dport 587 -j ACCEPT
	$v6 -A INPUT -p tcp -m state --state NEW --dport 465 -j ACCEPT
	$v6 -A INPUT -p tcp -m state --state NEW --dport 587 -j ACCEPT
}
Rule.mail() {
	notice "Firewall: arrange MAIL rules for mail receiving"
	# Accept MAIL connections from anywhere (standard ports for email receiving)
	$v4 -A INPUT -p tcp -m state --state NEW --dport 110 -j ACCEPT
	$v4 -A INPUT -p tcp -m state --state NEW --dport 143 -j ACCEPT
	$v4 -A INPUT -p tcp -m state --state NEW --dport 993 -j ACCEPT
	$v4 -A INPUT -p tcp -m state --state NEW --dport 995 -j ACCEPT
	$v6 -A INPUT -p tcp -m state --state NEW --dport 110 -j ACCEPT
	$v6 -A INPUT -p tcp -m state --state NEW --dport 143 -j ACCEPT
	$v6 -A INPUT -p tcp -m state --state NEW --dport 993 -j ACCEPT
	$v6 -A INPUT -p tcp -m state --state NEW --dport 995 -j ACCEPT
}
Rule.mysql() {
	notice "Firewall: arrange MYSQL rules"
	# Accept MYSQL connections from slaves
	$v4 -A INPUT -p tcp -m state --state NEW --dport 3306 -s smtp-e.rete.us,smtp-m.rete.us -j ACCEPT
	$v6 -A INPUT -p tcp -m state --state NEW --dport 3306 -s smtp-e.rete.us,smtp-m.rete.us -j ACCEPT
}
Rule.assp() {
	notice "Firewall: arrange ASSP rules"
	# Accept SSH connections on special port
	$v4 -A INPUT -p tcp -m state --state NEW --dport 22222 -j ACCEPT
	$v4 -A INPUT -p tcp -m state --state NEW --dport 55555 -j ACCEPT
#	$v4 -A INPUT -p tcp -m state --state NEW --dport 58725 -j ACCEPT
	$v6 -A INPUT -p tcp -m state --state NEW --dport 22222 -j ACCEPT
	$v6 -A INPUT -p tcp -m state --state NEW --dport 55555 -j ACCEPT
#	$v6 -A INPUT -p tcp -m state --state NEW --dport 58725 -j ACCEPT
}
Rule.ssh() {
	notice "Firewall: arrange SSH rules (Port: $SSHPORT)"
	# Accept SSH connections on special port
	$v4 -A INPUT -p tcp -m state --state NEW --dport $SSHPORT -j ACCEPT
	$v6 -A INPUT -p tcp -m state --state NEW --dport $SSHPORT -j ACCEPT
}
Ssh.restart() {
	# set port in /etc/ssh/sshd_config, then restart daemon
	sed -ri /etc/ssh/sshd_config \
		-e "s|^Port.*|Port $SSHPORT|"
	sed -ri $0 \
		-e"s|^SSHPORT=.*|SSHPORT=$SSHPORT|"
	cmd systemctl restart ssh
}
Fw.configure() {
	SSHPORT=$( Port.audit $SSHPORT )

	notice "Firewall: manage IPv4 & IPv6 basic common policies"
	$v4 -P INPUT DROP
	$v4 -P FORWARD DROP
	# Accepts all established inbound connections
	$v4 -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	# Accept all loopback (lo0) traffic and drop all traffic to 127/8 that not use lo0
	$v4 -A INPUT -i lo -j ACCEPT
	$v4 -A INPUT ! -i lo -d 127.0.0.0/8 -j REJECT
	# protect from some commons attack
	# drop incoming NEW tcp connections that are not SYN packets
	$v4 -A INPUT -m state --state NEW -p tcp ! --syn -j DROP
	# drop incoming packets with fragments, to inhibit Linux server panic
	$v4 -A INPUT -f -j DROP
	# drop incoming malformed XMAS & NULL packets
	$v4 -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
	$v4 -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

#	notice "Firewall: manage IPv6 basic policies"
	# these appear before any other rules
	$v6 -A INPUT -m rt --rt-type 0 --rt-segsleft 0 -j DROP
	$v6 -A FORWARD -m rt --rt-type 0 --rt-segsleft 0 -j DROP
	$v6 -A OUTPUT -m rt --rt-type 0 --rt-segsleft 0 -j DROP
	# Accepts all established inbound connections
	$v6 -P INPUT DROP
	$v6 -P FORWARD DROP
	# Accepts all established inbound connections
	$v6 -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	# Accept all traffic from/to the local interface.
	$v6 -A INPUT -i lo -j ACCEPT

#	notice "Firewall: manage IPv4 & IPv6 policies"
	local w
	for w in $ACCEPTS ; do
#		echo "[Rule.$w]"
		cmd "Rule.$w"
	done

	notice "Firewall: manage IPv4 & IPv6 icmp traffic"
	# Accepts IPv4 icmp
	$v4 -A INPUT -p icmp -m limit --limit 1/s --limit-burst 1 -j ACCEPT
	# Unlike with IPv4, is not a good idea to block ICMPv6 traffic as IPv6 is much more heavily dependent on it.
	$v6 -A INPUT -p icmpv6 -m limit --limit 1/s --limit-burst 1 -j ACCEPT
#	$v6 -A INPUT -p tcp -m tcp ! --syn -j ACCEPT

	notice "Firewall: logging IPv4 denied traffic"
	# Logging IPv4 omly
	$v4 -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 4

	# Drop all other connections
	$v4 -A INPUT -j DROP
	$v6 -A INPUT -j DROP

	# save in files
	[ $? -eq 0 ] && {
		$v4-save > /etc/iptables.v4.rules
		$v6-save > /etc/iptables.v6.rules
		notice "Firewall: rules saved successfully!"
		Ssh.restart
	} || {
		notice "Firewall: an error has occurred ( $? )"
	}
}


##	PROGRAM
##	############################################################################

case "$1" in
	start|restart)
		message "Starting firewall..."
		Fw.flush
		Fw.configure
		;;
	stop)
		message "Stopping firewall..."
		$v4 -F
		$v6 -F
		exit 0
		;;
	flush)
		Fw.flush
		;;
	*)
		message "Firewall status..."
		Fw.status
		message "Usage: $0 { start | restart | stop | status | flush }"
		;;
esac

