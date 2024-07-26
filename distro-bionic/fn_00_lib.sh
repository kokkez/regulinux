# ------------------------------------------------------------------------------
# custom functions specific to ubuntu 18.04 bionic
# ------------------------------------------------------------------------------

Menu.upgrade() {
	Msg.info "Upgrading system packages for ${ENV_os}..."
	Pkg.update	# update packages lists

	# stopping ubuntu-advantage-tools apt behavior
	local p='/etc/apt/apt.conf.d/20apt-esm-hook.conf'
	[ ! -e "$p.disabled" ] && [ -e "$p" ] && {
		cmd mv "$p" "$p.disabled"
		Msg.info "Renaming of the ubuntu-advantage-tools file '${p##*/}' completed!"
	}

	# do the apt upgrade
	export DEBIAN_FRONTEND=noninteractive
	cmd apt -qy full-upgrade
}	# end Menu.upgrade


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
