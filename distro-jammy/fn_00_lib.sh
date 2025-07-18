# ------------------------------------------------------------------------------
# custom functions specific to ubuntu 22.04 jammy
# ------------------------------------------------------------------------------

Arrange.unhang() {
	# mitigating ssh hang on reboot on systemd capables OSes
	# no more needed on ubuntu jammy
	Msg.debug "Arrange.unhang(): skipped (not needed on $ENV_os $ENV_arch)"
}	# end Arrange.unhang


Install.syslogd() {
	# no more needed, rsyslog is modern and default
	Msg.debug "Install.syslogd: skipped (rsyslog is modern and default)"
}	# end Install.syslogd


Menu.upgrade() {
	Msg.info "Upgrading system packages for ${ENV_os}..."
	Pkg.update	# update packages lists

	# do the apt upgrade
	export DEBIAN_FRONTEND=noninteractive
	apt -qy full-upgrade

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
}	# end Menu.upgrade


Net.info() {
	# return values for the network interface connected to the Internet
	# $1 - optional, desired result: if, mac, cidr, ip, gw, cidr6, ip6, gw6
	local if=$(ip r g 1 | grep -oP 'dev \K\S+')
	local mac=$(cat /sys/class/net/$if/address)
	mac=${mac:-00:00:00:00:00:00}
	local c4=$(ip -4 -br a s $if | awk '{print $3; exit}')
	local g4=$(ip r g 1 | grep -oP 'via \K\S+')
	g4=${g4:-0.0.0.0}
	local a4=${c4%%/*}

	# check if IPv6 is enabled
	local g6 a6 v=$(ip a s scope global)
	local c6=$(grep -oP 'inet6 \K\S+' <<< "$v")
	if [ -n "$c6" ]; then
		g6=$(ip r get :: | grep -oP 'via \K\S+')
		a6=${c6%%/*}
	fi

	case "$1" in
		m*)   echo $mac ;;
		c*6*) echo $c6 ;;
		c*)   echo $c4 ;;
		g*6*) echo $g6 ;;
		g*)   echo $g4 ;;
		i*6*) echo $a6 ;;
		if*)  echo $if ;;
		i*)   echo $a4 ;;
		*)    cat <<- EOF
			> Network Interface : $if
			> MAC Address       : $mac
			----------------------------------------------------------
			> IPv4 CIDR         : $c4
			> IPv4 Address      : $a4
			> IPv4 Gateway      : $g4
			----------------------------------------------------------
			> IPv6 CIDR         : ${c6:-N/A}
			> IPv6 Address      : ${a6:-N/A}
			> IPv6 Gateway      : ${g6:-N/A}
			----------------------------------------------------------
			EOF
	esac
}	# end Net.info


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
