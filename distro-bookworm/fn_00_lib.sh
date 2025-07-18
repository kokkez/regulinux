# ------------------------------------------------------------------------------
# custom functions specific to debian 12 bookworm
# ------------------------------------------------------------------------------

Arrange.unhang() {
	# mitigating ssh hang on reboot on systemd capables OSes
	# no more needed on debian 12
	Msg.debug "Arrange.unhang(): skipped (not needed on $ENV_os $ENV_arch)"
}	# end Arrange.unhang


Menu.upgrade() {
	Msg.info "Upgrading system packages for ${ENV_os}..."
	Pkg.update	# update packages lists

	# do the apt upgrade
	export DEBIAN_FRONTEND=noninteractive
	apt -qy full-upgrade
}	# end Menu.upgrade
