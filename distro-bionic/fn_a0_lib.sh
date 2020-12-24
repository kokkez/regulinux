# ------------------------------------------------------------------------------
# customized functions for ubuntu bionic
# ------------------------------------------------------------------------------

cmd() {
	# try run a real command, not an aliased version
	# on missing command, or error, it silently returns
	[ -n "${1}" ] && [ -n "$(command -v ${1})" ] && command "${@}"
};	# end cmd

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
