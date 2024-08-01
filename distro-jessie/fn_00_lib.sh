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


Menu.inet() {
	# print parameters related to network: ip, gw, interface (default)
	local v
	case "$1" in
		cidr6*) v=$(cmd ip -o -6 a | cmd awk '/global/ {print $4}') ;;
		cidr*)  v=$(cmd ip -o -4 a | cmd awk '/global/ {print $4}') ;;
		gw6*)   v=$(cmd ip -6 r | cmd grep -oP 'via \K\S+') ;;
		gw*)    v=$(cmd ip -4 r | cmd grep -oP 'via \K\S+') ;;
		ip6*)   v=$(cmd ip -6 r | cmd grep -oP 'src \K\S+') ;;
		ip*)    v=$(cmd ip -4 r | cmd grep -oP 'src \K\S+') ;;
		*)      v=$(cmd ip r | cmd awk '/default/ {print $NF}') ;;
	esac
	echo "$v";
}	# Menu.inet


Arrange.sources() {
	# install sources.list for apt
	File.into /etc/apt sources.list
	# get pgpkey from freexian
	File.download \
		https://deb.freexian.com/extended-lts/archive-key.gpg \
		/etc/apt/trusted.gpg.d/freexian-archive-extended-lts.gpg
	Msg.info "Installation of 'sources.list' for $ENV_os completed!"
}	# end Arrange.sources


svc_evoke() {
	# try to filter the service/init.d calls, for future upgrades
	local s=${1:-apache2} a=${2:-status}

	# stop if service is unavailable
	Cmd.usable "$s" || return

	Msg.info "Evoking ${s}.service to execute job ${a}..."

	[ "${a}" = "reload" ] && a="reload-or-restart"
	cmd systemctl ${a} ${s}.service
}	# end svc_evoke


Arrange.unhang() {
	# mitigating ssh hang on reboot on systemd capables OSes
	# no arguments expected
	local f='ssh-user-sessions.service'

	# install & enable a custom file
	[ -s "/etc/systemd/system/$f" ] || {
		File.into '/etc/systemd/system' "ssh/$f"
		cmd systemctl enable "$f"
		cmd systemctl start "$f"
		cmd systemctl daemon-reload
		Msg.info "Mitigation of 'SSH hangs on reboot' for $ENV_os completed"
	}
}	# end Arrange.unhang
