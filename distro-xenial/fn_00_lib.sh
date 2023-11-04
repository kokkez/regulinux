# ------------------------------------------------------------------------------
# customized functions for ubuntu xenial
# ------------------------------------------------------------------------------

Menu.upgrade() {
	Msg.info "Upgrading system packages for ${ENV_os}..."
	Pkg.update	# update packages lists

	# stopping ubuntu-advantage-tools apt behavior
	local p='/etc/apt/apt.conf.d/20apt-esm-hook.conf'
	[ -s "$p.disabled" ] || {
		[ -s "$p" ] && cmd mv "$p" "$p.disabled"
		Msg.info "Renaming of the ubuntu-advantage-tools file '${p##*/}' completed!"
	}

	# do the apt upgrade
	export DEBIAN_FRONTEND=noninteractive
	cmd apt -qy full-upgrade
}	# end Menu.upgrade


svc_evoke() {
	# try to filter the service/init.d calls, for future upgrades
	local s=${1:-apache2} a=${2:-status}

	# stop if service is unavailable
	Cmd.usable "$s" || return

	Msg.info "Evoking ${s}.service to execute job ${a}..."

	[ "$a" = "reload" ] && a="reload-or-restart"
	cmd systemctl $a ${s}.service
}	# end svc_evoke


Arrange.unhang() {
	# mitigating ssh hang on reboot
	# no arguments expected
	local f='ssh-user-sessions.service'

	# install & enable a custom file
	[ -s "/etc/systemd/system/$f" ] || {
		File.into '/etc/systemd/system' "ssh/$f"
		cmd systemctl enable "$f"
		cmd systemctl start "$f"
		cmd systemctl daemon-reload
		Msg.info "Mitigation of 'SSH hangs on reboot' for $ENV_os, completed"
	}

	# fix a systemd bug of xenial
	# https://askubuntu.com/questions/1109934/ssh-server-stops-working-after-reboot-caused-by-missing-var-run-sshd
	f='/usr/lib/tmpfiles.d/sshd.conf'
	cmd grep -q '/var' "$f" && {
		cmd sed -i "$f" -e 's|/var||'
#		cmd mkdir -p -m0755 /var/run/sshd
		Msg.info "Fixing a little systemd bug that prevent SSHd to start, completed"
	}
}	# end Arrange.unhang


Repo.php() {
	# add external repository for updated php
	local p='/etc/apt/sources.list.d/php.list'
	[ -s "$p" ] && return

	# add required software & the repo key
	Pkg.requires gnupg
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C
	cat > "$p" <<- EOF
		# Ondrej Sury Repo for PHP 7.x [ https://www.patreon.com/oerdnj ]
		deb http://ppa.launchpad.net/ondrej/php/ubuntu $ENV_codename main
		# deb-src http://ppa.launchpad.net/ondrej/php/ubuntu $ENV_codename main
		EOF
	# forcing apt update
	Pkg.update 'coerce'
}	# end Repo.php
