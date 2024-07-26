# ------------------------------------------------------------------------------
# custom functions specific to debian 11 bullseye
# ------------------------------------------------------------------------------

Menu.upgrade() {
	Msg.info "Upgrading system packages for ${ENV_os}..."
	Pkg.update	# update packages lists

	# do the apt upgrade
	export DEBIAN_FRONTEND=noninteractive
	cmd apt -qy full-upgrade
}	# end Menu.upgrade


Repo.php() {
	# add external repository for updated php
	local p='/etc/apt/sources.list.d/php.list'
	[ -s "$p" ] && return

	# add external repository for updated php
	Pkg.requires apt-transport-https lsb-release ca-certificates
	File.download https://packages.sury.org/php/apt.gpg /etc/apt/trusted.gpg.d/php.gpg
	cat > "$p" <<-EOF
		# https://www.patreon.com/oerdnj
		deb http://packages.sury.org/php $ENV_codename main
		#deb-src http://packages.sury.org/php $ENV_codename main
		EOF
	# forcing apt update
	Pkg.update 'coerce'
}	# end Repo.php


# legacy version of the iptables commands, needed by firewall
Fw.ip4() {
	cmd iptables-legacy "$@"
}
Fw.ip6() {
	cmd ip6tables-legacy "$@"
}
Fw.ip4save() {
	cmd iptables-legacy-save "$@"
}
Fw.ip6save() {
	cmd ip6tables-legacy-save "$@"
}


Arrange.sshd() {
	# configure SSH server parameters
	# $1: ssh port number, optional
	SSHD_PORT=$( Port.audit ${1:-$SSHD_PORT} )
	cmd sed -ri /etc/ssh/sshd_config \
		-e "s|^#?(Port)\s.*|\1 $SSHD_PORT|" \
		-e 's|^#?(PasswordAuthentication)\s.*|\1 no|' \
		-e 's|^#?(PermitRootLogin)\s.*|\1 without-password|' \
		-e 's|^#?(RSAAuthentication)\s.*|\1 yes|' \
		-e 's|^#?(PubkeyAuthentication)\s.*|\1 yes|'
	cmd systemctl restart ssh
	Config.set "SSHD_PORT" "$SSHD_PORT"
	Msg.info "SSH server is now listening on port: $SSHD_PORT"
}	# end Arrange.sshd


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

