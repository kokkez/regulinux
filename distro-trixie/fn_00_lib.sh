# ------------------------------------------------------------------------------
# custom functions specific to debian 13 trixie
# ------------------------------------------------------------------------------

Menu.advance() {
	# metadata for OS.menu entries
	__section='Standalone utilities'
	__summary="perform a full system upgrade via apt"

	Msg.info "Updating packages for ${ENV_os}..."
	Pkg.update	# update packages lists

	# do the apt upgrade
	Msg.info "Upgrading ${ENV_os}, if needed..."
	DEBIAN_FRONTEND=noninteractive apt -qy full-upgrade
}	# end Menu.advance


Arrange.sshd() {
	# configure SSH server parameters
	# $1: ssh port number, optional
	Pkg.requires openssh-server		# install if missing
	SSHD_PORT=$( Port.audit ${1:-$SSHD_PORT} )
	sed -ri "$ENV_dir/lib.sh" \
		-e "s|^(\s*SSHD_PORT=).*|\1'$SSHD_PORT'|"
	sed -ri /etc/ssh/sshd_config \
		-e "s|^#?(Port)\s.*|\1 $SSHD_PORT|" \
		-e 's|^#?(PasswordAuthentication)\s.*|\1 no|' \
		-e 's|^#?(PermitRootLogin)\s.*|\1 without-password|' \
		-e 's|^#?(PubkeyAuthentication)\s.*|\1 yes|'
	systemctl restart ssh
	Msg.info "SSH server is now listening on port: $SSHD_PORT"
}	# end Arrange.sshd


Install.syslogd() {
	# no more needed, rsyslog is modern and default
	Msg.debug "Install.syslogd: skipped (rsyslog is modern and default)"
}	# end Install.syslogd


Arrange.unhang() {
	# mitigating ssh hang on reboot on systemd capables OSes
	# no more needed on debian 12
	Msg.debug "Arrange.unhang(): skipped (not needed on $ENV_os $ENV_arch)"
}	# end Arrange.unhang
