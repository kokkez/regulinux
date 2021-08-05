# ------------------------------------------------------------------------------
# customized functions for jessie
# ------------------------------------------------------------------------------

Menu.upgrade() {
	Msg.info "Upgrading system packages for ${ENV_os}..."
	Pkg.update	# update packages lists

	# do the apt-get upgrade
	export DEBIAN_FRONTEND=noninteractive
	apt-get -qy dist-upgrade
}	# end Menu.upgrade


svc_evoke() {
	# try to filter the service/init.d calls, for future upgrades
	local s=${1:-apache2} a=${2:-status}

	# stop if service is unavailable
	Cmd.usable "$s" || return

	Msg.info "Evoking ${s}.service to execute job ${a}..."

	[ "${a}" = "reload" ] && a="reload-or-restart"
	cmd systemctl ${a} ${s}.service
}	# end svc_evoke


SSH.antihangs() {
	# mitigating ssh hang on reboot on systemd capables OSes
	# no arguments expected
	local f='ssh-user-sessions.service'

	# install & enable a custom file
	[ -s "/etc/systemd/system/$f" ] || {
		Msg.info "Mitigating the problem of SSH hangs on reboot"
		File.into '/etc/systemd/system' "ssh/$f"
		cmd systemctl enable "$f"
		cmd systemctl start "$f"
		cmd systemctl daemon-reload
	}
}	# end SSH.antihangs
