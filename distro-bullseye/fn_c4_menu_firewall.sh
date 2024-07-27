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


Fw.allow() {
	# enable ports on ufw firewall
	# $1 - keyword for ufw
	Arg.expect "$1" || return

	# allow port/type
	cmd ufw allow "$1"

	# save the new value back into settings file
	Config.set "FW_allowed" "$FW_allowed $1"
};	# end Fw.allow
