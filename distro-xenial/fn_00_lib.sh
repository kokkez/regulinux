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

Menu.upgrade() {
	Msg.info "Upgrading system packages for ${ENV_os}..."
	Pkg.update	# update packages lists

	# do the apt upgrade
	export DEBIAN_FRONTEND=noninteractive
	cmd apt -qy full-upgrade
}	# end Menu.upgrade

# ------------------------------------------------------------------------------

Repo.php() {
	# add external repository for updated php
	local p='/etc/apt/sources.list.d/php.list'
	[ -s "$p" ] && return

	# add required software & the repo key
	Pkg.requires gnupg
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C
	cat > "$p" <<EOF
# Ondrej Sury Repo for PHP 7.x [ https://www.patreon.com/oerdnj ]
deb http://ppa.launchpad.net/ondrej/php/ubuntu $ENV_codename main
# deb-src http://ppa.launchpad.net/ondrej/php/ubuntu $ENV_codename main
EOF
	# forcing apt update
	Pkg.update 'coerce'
}	# end Repo.php
