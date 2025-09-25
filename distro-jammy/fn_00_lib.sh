# ------------------------------------------------------------------------------
# custom functions specific to ubuntu 22.04 jammy
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

	# disable ubuntu-advantage-tools apt hook if present
	local p='/etc/apt/apt.conf.d/20apt-esm-hook.conf'
	# skip if already disabled
	[ -e "$p.disabled" ] || {
		[ -e "$p" ] && {
			mv "$p" "$p.disabled"
			Msg.info "Disabling apt hook: ${p##*/}, completed!"
		}
	}

	# remove every file in /etc/update-motd.d
	shopt -s nullglob
	p=(/etc/update-motd.d/*)
	shopt -u nullglob
	if (( ${#p[@]} )); then
		rm -f "${p[@]}"
		Msg.info "Removed ${#p[@]} files in /etc/update-motd.d/"
	fi
}	# end Menu.advance


Repo.php() {
	# add external repository for updated php
	local p='/etc/apt/sources.list.d/php.list'
	[ -s "$p" ] && return

	# add required software & the repo key
	Pkg.requires gnupg
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
	cat > "$p" <<EOF
# Ondrej Sury Repo for PHP 7.x [ https://www.patreon.com/oerdnj ]
deb http://ppa.launchpad.net/ondrej/php/ubuntu $ENV_codename main
# deb-src http://ppa.launchpad.net/ondrej/php/ubuntu $ENV_codename main
EOF
	# forcing apt update
	Pkg.update 'coerce'
}	# end Repo.php


Arrange.unhang() {
	# mitigating ssh hang on reboot on systemd capables OSes
	# no more needed on ubuntu jammy
	Msg.debug "Arrange.unhang(): skipped (not needed on $ENV_os $ENV_arch)"
}	# end Arrange.unhang


Install.syslogd() {
	# no more needed, rsyslog is modern and default
	Msg.debug "Install.syslogd: skipped (rsyslog is modern and default)"
}	# end Install.syslogd


OS.minimalize() {
	# placeholder, do nothing
	Msg.debug "placeholder Fn, provide a real function to minimalize the OS"
}	# end OS.minimalize


Install.firewall() {
	# placeholder, do nothing
	Msg.debug "placeholder Fn, provide a real function to manage firewall rules"
}	# end Install.firewall
