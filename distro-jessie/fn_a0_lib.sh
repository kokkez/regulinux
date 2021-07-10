# ------------------------------------------------------------------------------
# customized functions for jessie
# ------------------------------------------------------------------------------

menu_upgrade() {
	Msg.info "Upgrading system packages for ${ENV_os}..."
	pkg_update	# update packages lists

	# do the apt-get upgrade
	export DEBIAN_FRONTEND=noninteractive
	apt-get -qy dist-upgrade
}	# end menu_upgrade


svc_evoke() {
	# try to filter the service/init.d calls, for future upgrades
	local s=${1:-apache2} a=${2:-status}

	# stop if service is unavailable
	Cmd.usable "$s" || return

	Msg.info "Evoking ${s}.service to execute job ${a}..."

	[ "${a}" = "reload" ] && a="reload-or-restart"
	cmd systemctl ${a} ${s}.service
}	# end svc_evoke
