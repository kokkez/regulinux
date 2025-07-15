# ------------------------------------------------------------------------------
# custom functions specific to ubuntu 22.04 jammy
# ------------------------------------------------------------------------------

Menu.upgrade() {
	Msg.info "Upgrading system packages for ${ENV_os}..."
	Pkg.update	# update packages lists

	# stopping ubuntu-advantage-tools apt behavior
	local p='/etc/apt/apt.conf.d/20apt-esm-hook.conf'
	[ -s "$p.disabled" ] || {
		[ -s "$p" ] && mv "$p" "$p.disabled"
		Msg.info "Renaming of the ubuntu-advantage-tools file '${p##*/}' completed!"
	}

	# do the apt upgrade
	export DEBIAN_FRONTEND=noninteractive
	apt -qy full-upgrade
}	# end Menu.upgrade


Net.info() {
	# print parameters related to network: ip, gw, interface (default)
	local v=$(ip a s scope global)

	if [[ "$1" == *6* ]]; then
		# check if IPv6 is enabled
		grep -qP 'inet6 \K\S+' <<< "$v" || return
	fi
	case "$1" in
		cidr6*) v=$( grep -oP 'inet6 \K\S+' <<< "$v" ) ;;
		cidr*)  v=$( grep -oP 'inet \K\S+' <<< "$v" ) ;;
		gw6*)   v=$( ip r get :: | grep -oP 'via \K\S+' ) ;;
		gw*)    v=$( ip r get 1 | grep -oP 'via \K\S+' ) ;;
		ip6*)   v=$( Net.info cidr6 ); v="${v%%/*}" ;;
		ip*)    v=$( Net.info cidr ); v="${v%%/*}" ;;
		*)      v=$( ip r get 1 | grep -oP 'dev \K\S+' ) ;;
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
