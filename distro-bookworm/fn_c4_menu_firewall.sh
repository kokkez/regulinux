# ------------------------------------------------------------------------------
# the OS firewall specific to debian 12 bookworm
# ------------------------------------------------------------------------------

# overwrite commands to make them innocuous
Fw.ip4()     { :; }
Fw.ip6()     { :; }
Fw.ip4save() { :; }
Fw.ip6save() { :; }


Fw.notice() {
	echo -e \
		$(Dye.fg.green 'FireWall') \
		$(Dye.fg.green.lite '>>') \
		$(Dye.fg.white "$@")
};	# end Fw.notice


Fw.rule.vpn() {
	# accept VPN connections on given (or default) port
	local p=${1:-1194}
	Fw.notice "appending VPN rules for port $p"

	# allow VPN traffic on tun0 interface
	ufw allow in on tun0
	# allow forwarding from tun0 to venet0 and vice versa
	ufw route allow in on tun0 out on venet0
	ufw route allow in on venet0 out on tun0
	# allow VPN UDP traffic on specified port
	ufw allow in on venet0 proto udp to any port "$p"
	# enable NAT for VPN subnet
	echo 1 > /proc/sys/net/ipv4/ip_forward

	# append NAT rules to /etc/ufw/before.rules using a heredoc
	p="/etc/ufw/before.rules"
	if ! grep -q "^*nat" "$p"; then
		cat <<-EOF >> "$p"
		*nat
		:POSTROUTING ACCEPT [0:0]
		-A POSTROUTING -s 10.8.0.0/24 -o venet0 -j MASQUERADE
		COMMIT
		EOF
	else
		sed -i "/^COMMIT/i -A POSTROUTING -s 10.8.0.0/24 -o venet0 -j MASQUERADE" "$p"
	fi

	# reload UFW to apply changes
	ufw reload
};	# end Fw.rule.vpn
Fw.rule.dns() {
	Fw.notice "appending DNS rules"
	ufw allow 53
};	# end Fw.rule.dns
Fw.rule.ftp() {
	Fw.notice "appending FTP rules"
	ufw allow 21,40110:40210/tcp
};	# end Fw.rule.ftp
Fw.rule.ispconfig() {
	Fw.notice "appending ISPConfig rules"
	ufw allow 8080,8081/tcp
};	# end Fw.rule.ispconfig
Fw.rule.http() {
	Fw.notice "appending HTTP and HTTPS rules"
	ufw allow 80,443/tcp
};	# end Fw.rule.http
Fw.rule.smtp() {
	Fw.notice "appending SMTP rules for port 25"
	ufw allow 25/tcp
};	# end Fw.rule.smtp
Fw.rule.smtps() {
	Fw.notice "appending SMTP rules for SSL/TLS ports"
	ufw allow 465,587/tcp
};	# end Fw.rule.smtps
Fw.rule.mail() {
	Fw.notice "appending MAIL rules for mail receiving"
	ufw allow 110,143,993,995/tcp
};	# end Fw.rule.mail
Fw.rule.mysql() {
	Fw.notice "appending MYSQL rules"
    ufw allow from smtp-m.rete.us to 3306/tcp
    ufw allow from smtp-r.rete.us to 3306/tcp
};	# end Fw.rule.mysql
Fw.rule.assp() {
	Fw.notice "appending ASSP rules"
	ufw allow 22222,55555,58725/tcp
};	# end Fw.rule.assp
Fw.rule.ssh() {
	Fw.notice "appending SSH rules (Port: $SSHD_PORT)"
	ufw allow $SSHD_PORT/tcp
};	# end Fw.rule.ssh


Fw.uniquize() {
	# given a string with "words" it remowes duplicates
	# $1+ - one or more arguments
	Arg.expect "$1" || return

	# unique-ize arguments
	local a w
	for w in $*; do Element.in $w $a || a+=" $w"; done

	echo "${a:1}"
};	# end Fw.uniquize


Fw.allow() {
	# enable ports on ufw firewall
	# $1+ - keyword for ufw
	Arg.expect "$1" || return

	# allow via keyword one by one
	local w a
	for w in $(Fw.uniquize $*)
	do
		Cmd.usable "Fw.rule.$w" && Fw.rule.$w && a+=" $w"
	done

	# save the new value back into settings file
	Config.set "FW_allowed" "$(Fw.uniquize $FW_allowed $a)"

#	ufw --force enable
	ufw --force reload
};	# end Fw.allow


Fw.deny() {
	# enable ports on ufw firewall
	# $1 - keyword for ufw
	Arg.expect "$1" || return

	# deny port/type one by one
	local c w a=$(Fw.uniquize $*)
	for w in $a; do ufw deny "$w"; done

	# cleanup $FW_allowed
	for w in $FW_allowed; do Element.in $w $a || c+=" $w"; done

	# save the new value back into settings file
	Config.set "FW_allowed" "$(Fw.uniquize $c)"
};	# end Fw.deny


Install.firewall() {
	# installing firewall, using ufw
	# $1 - ssh port number, optional
	SSHD_PORT=$( Port.audit ${1:-$SSHD_PORT} )	# strictly numeric port

	# install required software
	Pkg.requires ufw

	# enable firewall so it can be loaded at every boot
	ufw --force reset
	ufw --force enable
	systemctl enable ufw
	ufw logging off

	# allow our SSHD_PORT & save in settings file
	Fw.allow 'ssh'
	Config.set "SSHD_PORT" "$SSHD_PORT"

	Msg.info "Firewall installation and configuration completed!"
};	# end Install.firewall


Menu.firewall() {
	# show status
	local kw=${1:+numbered}
	kw=${kw:-verbose}
	Fw.notice "Show firewall status: $kw"
	ufw status $kw
};	# end Menu.firewall

Menu.deny()  { Fw.deny "$@"; }			# alias fn
Menu.allow() { Fw.allow "$@"; }			# alias fn
Menu.fw()    { Menu.firewall "$@"; }	# alias fn
