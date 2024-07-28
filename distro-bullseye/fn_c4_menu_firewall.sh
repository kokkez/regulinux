# ------------------------------------------------------------------------------
# the OS firewall specific to debian 12 bookworm
# ------------------------------------------------------------------------------

Install.firewall() {
	# installing firewall, using ufw
	# $1 - ssh port number, optional
	SSHD_PORT=$( Port.audit ${1:-$SSHD_PORT} )	# strictly numeric port

	# install required software
	Pkg.requires ufw

	# enable firewall so it can be loaded at every boot
	cmd ufw --force reset
	cmd ufw --force enable
	cmd systemctl enable ufw

	# allow our SSHD_PORT
	cmd ufw allow $SSHD_PORT/tcp

	# save into settings file
	Config.set "SSHD_PORT" "$SSHD_PORT"

	Msg.info "Firewall installation and configuration completed!"
}	# end Install.firewall


Menu.firewall() {
	# show status
	cmd ufw status verbose
}	# end Menu.firewall


Fw.uniquize() {
	# given a string with "words" it remowes duplicates
	# $1+ - one or more arguments
	Arg.expect "$1" || return

	# unique-ize arguments
	local a w
	for w in $*; do Element.in $w $a || a+=" $w"; done

	echo "${a:1}"
}	# end Fw.uniquize


Fw.allow() {
	# enable ports on ufw firewall
	# $1+ - keyword for ufw
	Arg.expect "$1" || return

	# allow port/type one by one
	local w a=$(Fw.uniquize $*)
	for w in $a; do cmd ufw allow "$w"; done

	# save the new value back into settings file
	Config.set "FW_allowed" "$(Fw.uniquize $FW_allowed $a)"
};	# end Fw.allow


Fw.deny() {
	# enable ports on ufw firewall
	# $1 - keyword for ufw
	Arg.expect "$1" || return

	# deny port/type one by one
	local c w a=$(Fw.uniquize $*)
	for w in $a; do cmd ufw deny "$w"; done

	# cleanup $FW_allowed
	for w in $FW_allowed; do Element.in $w $a || c+=" $w"; done

	# save the new value back into settings file
	Config.set "FW_allowed" "$(Fw.uniquize $c)"
};	# end Fw.allow
