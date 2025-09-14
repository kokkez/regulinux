# ------------------------------------------------------------------------------
# custom functions specific to debian 13 trixie
# ------------------------------------------------------------------------------

Install.syslogd() {
	# no more needed, rsyslog is modern and default
	Msg.debug "Install.syslogd: skipped (rsyslog is modern and default)"
}	# end Install.syslogd


Arrange.unhang() {
	# mitigating ssh hang on reboot on systemd capables OSes
	# no more needed on debian 12
	Msg.debug "Arrange.unhang(): skipped (not needed on $ENV_os $ENV_arch)"
}	# end Arrange.unhang


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
