# ------------------------------------------------------------------------------
# custom functions specific to debian 12 bookworm
# ------------------------------------------------------------------------------

Menu.upgrade() {
	Msg.info "Upgrading system packages for ${ENV_os}..."
	Pkg.update	# update packages lists

	# do the apt upgrade
	export DEBIAN_FRONTEND=noninteractive
	apt -qy full-upgrade
}	# end Menu.upgrade
