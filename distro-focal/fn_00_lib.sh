# ------------------------------------------------------------------------------
# custom functions specific to ubuntu 20.04 focal
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


Install.firewall() {
	# setup firewall using firewalld via nftables
	# https://blog.myhro.info/2021/12/configuring-firewalld-on-debian-bullseye
	# $1 - ssh port number, optional

	# add required software & purge unwanted
	Pkg.requires firewalld
#	Pkg.purge "ufw"

	SSHD_PORT=$( Port.audit ${1:-$SSHD_PORT} )	# strictly numeric port

	# remove default ports, permanently
	cmd firewall-cmd -q --remove-service={dhcpv6-client,ssh}

	# make our ssh persistent, so that can be loaded at every boot
	cmd firewall-cmd -q --add-port=$p/tcp

	# set packets to be silently dropped, instead of actively rejected
#	cmd firewall-cmd -q --set-target DROP

	# reload configuration
	cmd firewall-cmd -q --runtime-to-permanent

	Msg.info "Firewall installation and setup completed!"
}	# end Install.firewall
