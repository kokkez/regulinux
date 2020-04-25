#!/bin/bash
### BEGIN INIT INFO
# Provides:          firewall
# Required-Start:
# Required-Stop:
# Should-Start:
# Default-Start:
# Default-Stop:
# Short-Description: Firewall manager
# Description:       Firewall script for OpenVZ containers
### END INIT INFO


##	CHECK AND CHANGE OPTION BELOW HERE!
##	############################################################################

# Ports that will be opened
SSHPORT=22
ACCEPTS="ssh"


##	DO NOT CHANGE ANYTHING BELOW HERE!
##	############################################################################
# paths to iptables (IPv4 only) & ip6tables (IPv6 only)
IP4=$(command -v iptables)
IP6=$(command -v ip6tables)

message() {
	echo -e "\e[1;32m>> \e[1;37m$* \e[1;32m<<\e[0m"
}
notice() {
	echo -e "\e[2;32m>> \e[1;37m$*\e[0m"
}
cmd() {
	# run a command without returning errors
	[ -n "${1}" ] && {
		local c="$(command -v ${1})"
		shift && [ -n "${c}" ] && ${c} "${@}"
	}
}
port_limit() {
	# set port in $1 to be strictly numeric & in range
	local T L P=$(cmd awk '{print int($1)}' <<< ${1-22})
	[ ${P} -eq 22 ] || {
		# limit min & max range
		P=$(( P > 65534 ? 65535 : P < 1025 ? 1024 : P ))
		# exclude net.ipv4.ip_local_port_range
		T=$(cmd sysctl -e -n net.ipv4.ip_local_port_range)
		L=$(cmd awk '{print int($1)}' <<< ${T})
		T=$(cmd awk '{print int($2)}' <<< ${T})
		P=$(( P < ${L} ? P : P > ${T} ? P : 64128 ))
	}
	echo ${P}
}
status() {
	notice "Firewall: current IPv4 rules"
	${IP4} -nvL
	echo
	notice "Firewall: current IPv6 rules"
	${IP6} -nvL
	echo
}
flushall() {
	notice "Firewall: flushing current rules from memory and allowing all traffic"
	${IP4} -F
	${IP4} -P OUTPUT ACCEPT
	${IP6} -F
	${IP6} -P OUTPUT ACCEPT
}
manage_vpn() {
	notice "Firewall: arrange VPN rules"
	# Accept VPN connections from anywhere
	# remember to customize the port before use
	${IP4} -t nat -I POSTROUTING 1 -s 10.8.0.0/24 -o venet0 -j MASQUERADE
	${IP4} -I INPUT 1 -i tun0 -j ACCEPT
	${IP4} -I FORWARD 1 -i venet0 -o tun0 -j ACCEPT
	${IP4} -I FORWARD 1 -i tun0 -o venet0 -j ACCEPT
	${IP4} -I INPUT 1 -i venet0 -p udp --dport 1194 -j ACCEPT
}
manage_dns() {
	notice "Firewall: arrange DNS rules"
	# Accept DNS connections from anywhere
	${IP4} -A INPUT -p tcp -m state --state NEW --dport 53 -j ACCEPT
	${IP4} -A INPUT -p udp -m state --state NEW --dport 53 -j ACCEPT
	${IP6} -A INPUT -p tcp -m state --state NEW --dport 53 -j ACCEPT
	${IP6} -A INPUT -p udp -m state --state NEW --dport 53 -j ACCEPT
}
manage_ftp() {
	notice "Firewall: arrange FTP rules"
	# Accept FTP connections from anywhere (+ pure-ftpd passive ports)
	${IP4} -A INPUT -p tcp -m state --state NEW --dport 21 -j ACCEPT
	${IP4} -A INPUT -p tcp -m state --state NEW --dport 40010:40910 -j ACCEPT
	${IP6} -A INPUT -p tcp -m state --state NEW --dport 21 -j ACCEPT
	${IP6} -A INPUT -p tcp -m state --state NEW --dport 40010:40910 -j ACCEPT
}
manage_ispconfig() {
	notice "Firewall: arrange ISPConfig rules"
	# Accept HTTP connections from anywhere
	${IP4} -A INPUT -p tcp -m state --state NEW --dport 8080 -j ACCEPT
	${IP6} -A INPUT -p tcp -m state --state NEW --dport 8080 -j ACCEPT
}
manage_http() {
	notice "Firewall: arrange HTTP and HTTPS rules"
	# Accept HTTP and HTTPS connections from anywhere (standard ports for websites)
	${IP4} -A INPUT -p tcp -m state --state NEW --dport 80 -j ACCEPT
	${IP4} -A INPUT -p tcp -m state --state NEW --dport 443 -j ACCEPT
	${IP6} -A INPUT -p tcp -m state --state NEW --dport 80 -j ACCEPT
	${IP6} -A INPUT -p tcp -m state --state NEW --dport 443 -j ACCEPT
}
manage_smtp() {
	notice "Firewall: arrange SMTP rules for port 25"
	# Accept SMTP connections from anywhere (port 25 for email sending)
	${IP4} -A INPUT -p tcp -m state --state NEW --dport 25 -j ACCEPT
	${IP6} -A INPUT -p tcp -m state --state NEW --dport 25 -j ACCEPT
}
manage_ssltls() {
	notice "Firewall: arrange SMTP rules with SSL/TLS"
	# Accept SMTP connections from anywhere (standard ports for email sending)
	${IP4} -A INPUT -p tcp -m state --state NEW --dport 465 -j ACCEPT
	${IP4} -A INPUT -p tcp -m state --state NEW --dport 587 -j ACCEPT
	${IP6} -A INPUT -p tcp -m state --state NEW --dport 465 -j ACCEPT
	${IP6} -A INPUT -p tcp -m state --state NEW --dport 587 -j ACCEPT
}
manage_mail() {
	notice "Firewall: arrange MAIL rules for mail receiving"
	# Accept MAIL connections from anywhere (standard ports for email receiving)
	${IP4} -A INPUT -p tcp -m state --state NEW --dport 110 -j ACCEPT
	${IP4} -A INPUT -p tcp -m state --state NEW --dport 143 -j ACCEPT
	${IP4} -A INPUT -p tcp -m state --state NEW --dport 993 -j ACCEPT
	${IP4} -A INPUT -p tcp -m state --state NEW --dport 995 -j ACCEPT
	${IP6} -A INPUT -p tcp -m state --state NEW --dport 110 -j ACCEPT
	${IP6} -A INPUT -p tcp -m state --state NEW --dport 143 -j ACCEPT
	${IP6} -A INPUT -p tcp -m state --state NEW --dport 993 -j ACCEPT
	${IP6} -A INPUT -p tcp -m state --state NEW --dport 995 -j ACCEPT
}
manage_mysql() {
	notice "Firewall: arrange MYSQL rules"
	# Accept MYSQL connections from slaves
	${IP4} -A INPUT -p tcp -m state --state NEW --dport 3306 -s ethika.rete.us,malika.rete.us -j ACCEPT
	${IP6} -A INPUT -p tcp -m state --state NEW --dport 3306 -s ethika.rete.us,malika.rete.us -j ACCEPT
}
manage_assp() {
	notice "Firewall: arrange ASSP rules"
	# Accept SSH connections on special port
	${IP4} -A INPUT -p tcp -m state --state NEW --dport 22222 -j ACCEPT
	${IP4} -A INPUT -p tcp -m state --state NEW --dport 55555 -j ACCEPT
#	${IP4} -A INPUT -p tcp -m state --state NEW --dport 58725 -j ACCEPT
	${IP6} -A INPUT -p tcp -m state --state NEW --dport 22222 -j ACCEPT
	${IP6} -A INPUT -p tcp -m state --state NEW --dport 55555 -j ACCEPT
#	${IP6} -A INPUT -p tcp -m state --state NEW --dport 58725 -j ACCEPT
}
manage_ssh() {
	notice "Firewall: arrange SSH rules (Port: ${SSHPORT})"
	# Accept SSH connections on special port
	${IP4} -A INPUT -p tcp -m state --state NEW --dport ${SSHPORT} -j ACCEPT
	${IP6} -A INPUT -p tcp -m state --state NEW --dport ${SSHPORT} -j ACCEPT
}
restart_sshd() {
	# configure port in /etc/ssh/sshd_config, then restart daemon
	sed -ri "s|^Port.*|Port ${SSHPORT}|" /etc/ssh/sshd_config
	sed -ri "s|^SSHPORT=.*|SSHPORT=${SSHPORT}|" ${0}
	/etc/init.d/ssh restart
}
configure() {
	SSHPORT=$(port_limit ${SSHPORT})

	notice "Firewall: manage IPv4 & IPv6 basic common policies"
	${IP4} -P INPUT DROP
	${IP4} -P FORWARD DROP
	# Accepts all established inbound connections
	${IP4} -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	# Accept all loopback (lo0) traffic and drop all traffic to 127/8 that not use lo0
	${IP4} -A INPUT -i lo -j ACCEPT
	${IP4} -A INPUT ! -i lo -d 127.0.0.0/8 -j REJECT
	# protect from some commons attack
	# drop incoming NEW tcp connections that are not SYN packets
	${IP4} -A INPUT -m state --state NEW -p tcp ! --syn -j DROP
	# drop incoming packets with fragments, to inhibit Linux server panic
	${IP4} -A INPUT -f -j DROP
	# drop incoming malformed XMAS & NULL packets
	${IP4} -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
	${IP4} -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

#	notice "Firewall: manage IPv6 basic policies"
	# these appear before any other rules
	${IP6} -A INPUT -m rt --rt-type 0 --rt-segsleft 0 -j DROP
	${IP6} -A FORWARD -m rt --rt-type 0 --rt-segsleft 0 -j DROP
	${IP6} -A OUTPUT -m rt --rt-type 0 --rt-segsleft 0 -j DROP
	# Accepts all established inbound connections
	${IP6} -P INPUT DROP
	${IP6} -P FORWARD DROP
	# Accepts all established inbound connections
	${IP6} -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	# Accept all traffic from/to the local interface.
	${IP6} -A INPUT -i lo -j ACCEPT

#	notice "Firewall: manage IPv4 & IPv6 policies"
	for svc in ${ACCEPTS} ; do
#		echo ${svc}
		cmd "manage_${svc}"
	done

	notice "Firewall: manage IPv4 & IPv6 icmp traffic"
	# Accepts IPv4 icmp
	${IP4} -A INPUT -p icmp -m limit --limit 1/s --limit-burst 1 -j ACCEPT
	# Unlike with IPv4, is not a good idea to block ICMPv6 traffic as IPv6 is much more heavily dependent on it.
	${IP6} -A INPUT -p icmpv6 -m limit --limit 1/s --limit-burst 1 -j ACCEPT
#	${IP6} -A INPUT -p tcp -m tcp ! --syn -j ACCEPT

	notice "Firewall: logging IPv4 denied traffic"
	# Logging IPv4 omly
	${IP4} -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 4

	# Drop all other connections
	${IP4} -A INPUT -j DROP
	${IP6} -A INPUT -j DROP

	# save in files
	[ $? -eq 0 ] && {
		cmd iptables-save > /etc/iptables.v4.rules
		cmd ip6tables-save > /etc/iptables.v6.rules
		notice "Firewall: rules saved successfully!"
		restart_sshd
	} || {
		notice "Firewall: an error has occurred ( $? )"
	}
}


##	PROGRAM
##	############################################################################

case "$1" in
	start|restart)
		message "Starting firewall..."
		flushall
		configure
		;;
	stop)
		message "Stopping firewall..."
		${IP4} -F
		${IP6} -F
		exit 0
		;;
	flush)
		flushall
		;;
	*)
		message "Firewall status..."
		status
		message "Usage: $0 { start | restart | stop | status | flush }"
		;;
esac

