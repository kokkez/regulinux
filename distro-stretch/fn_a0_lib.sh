# ------------------------------------------------------------------------------
# customized functions for debian stretch
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
	local P="/etc/apt/sources.list.d/php.list"

	# add external repository for updated php
	[ -s ${P} ] || {
		is_installed "apt-transport-https" || {
			msg_info "Installing required packages..."
			pkg_install apt-transport-https lsb-release ca-certificates
		}
		down_load https://packages.sury.org/php/apt.gpg /etc/apt/trusted.gpg.d/php.gpg
		cat > ${P} <<EOF
# https://www.patreon.com/oerdnj
deb http://packages.sury.org/php stretch main
#deb-src http://packages.sury.org/php stretch main
EOF

		# forcing apt update
		pkg_update true
	}
}	# end add_php_repository
