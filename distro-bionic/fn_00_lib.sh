# ------------------------------------------------------------------------------
# custom functions specific to ubuntu 18.04 bionic
# ------------------------------------------------------------------------------

Menu.upgrade() {
	# metadata for OS.menu entries
	__section='Standalone utilities'
	__summary="perform a full system upgrade via apt"

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


Net.info() {
	# print parameters related to network: ip, gw, interface (default)
	local v=$(cmd ip a s scope global)

	if [[ "$1" == *6* ]]; then
		# check if IPv6 is enabled
		cmd grep -qP 'inet6 \K\S+' <<< "$v" || return
	fi
	case "$1" in
		cidr6*) v=$( cmd grep -oP 'inet6 \K\S+' <<< "$v" ) ;;
		cidr*)  v=$( cmd grep -oP 'inet \K\S+' <<< "$v" ) ;;
		gw6*)   v=$( cmd ip r get :: | cmd grep -oP 'via \K\S+' ) ;;
		gw*)    v=$( cmd ip r get 1 | cmd grep -oP 'via \K\S+' ) ;;
		ip6*)   v=$( Net.info cidr6 ); v="${v%%/*}" ;;
		ip*)    v=$( Net.info cidr ); v="${v%%/*}" ;;
		*)      v=$( cmd ip r get 1 | cmd grep -oP 'dev \K\S+' ) ;;
	esac
	echo "$v";
}	# Net.info


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
