# ------------------------------------------------------------------------------
# customized functions for ubuntu xenial
# ------------------------------------------------------------------------------

svc_evoke() {
	# try to filter the service/init.d calls, for future upgrades
	local s=${1:-apache2} a=${2:-status}

	# stop if service is unavailable
	Cmd.usable "$s" || return

	Msg.info "Evoking ${s}.service to execute job ${a}..."

	[ "$a" = "reload" ] && a="reload-or-restart"
	cmd systemctl $a ${s}.service
}	# end svc_evoke

# ------------------------------------------------------------------------------

menu_upgrade() {
	Msg.info "Upgrading system packages for ${ENV_os}..."
	pkg_update	# update packages lists

	# do the apt upgrade
	export DEBIAN_FRONTEND=noninteractive
	cmd apt -qy full-upgrade
}	# end menu_upgrade

# ------------------------------------------------------------------------------

add_php_repository() {
	# append external repository to sources.list for updated php
	cd /etc/apt
	grep -q 'Ondrej Sury' sources.list || {
		pkg_require gnupg
		apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C
		cat >> sources.list <<EOF

# Ondrej Sury Repo for PHP 7.x [ https://www.patreon.com/oerdnj ]
deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main
# deb-src http://ppa.launchpad.net/ondrej/php/ubuntu xenial main
EOF
	}

	# forcing apt update
	pkg_update true
}	# end add_php_repository
