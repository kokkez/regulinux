# ------------------------------------------------------------------------------
# customized functions for ubuntu bionic
# ------------------------------------------------------------------------------

svc_evoke() {
	# try to filter the service/init.d calls, for future upgrades
	local s=${1:-apache2} a=${2:-status}

	# stop if service is unavailable
	is_available "${s}" || return

	msg_info "Evoking ${s}.service to execute job ${a}..."

	[ "${a}" = "reload" ] && a="reload-or-restart"
	cmd systemctl ${a} ${s}.service
}	# end svc_evoke

# ------------------------------------------------------------------------------

menu_upgrade() {
	msg_info "Upgrading system packages for ${OS} (${DISTRO})..."
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
		apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
		cat >> sources.list <<EOF

# Ondrej Sury Repo for PHP 7.x [ https://www.patreon.com/oerdnj ]
deb http://ppa.launchpad.net/ondrej/php/ubuntu bionic main
# deb-src http://ppa.launchpad.net/ondrej/php/ubuntu bionic main
EOF
	}

	# forcing apt update
	pkg_update true
}	# end add_php_repository
