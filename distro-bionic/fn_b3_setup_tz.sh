# ------------------------------------------------------------------------------
# customize timezone & localtime
# ------------------------------------------------------------------------------

config_tz() {
	local A Z T=${1:-${TIME_ZONE}}

	[ -f "/usr/share/zoneinfo/${T}" ] || {
		msg_error "The requested timezone does not exists: ${T}"
	}

	# split into variables
	A=${T%%/*} Z=${T#*/}
	msg_info "Setup timezone as AREA: '${A}', ZONE: '${Z}'"

	# backup old first, then get the new from zoneinfo file
	backup_file /etc/localtime
	rm -f /etc/localtime
	cp "/usr/share/zoneinfo/${T}" /etc/localtime
	echo "${T}" > /etc/timezone		# also write in /etc/timezone

	# preseed tzdata, then reconfigure
	debconf-set-selections <<EOF
tzdata tzdata/Areas select ${A}
tzdata tzdata/Zones/${A} select ${Z}
EOF
	dpkg-reconfigure -f noninteractive tzdata > /dev/null 2>&1

	# Show the new setting on the shell
	A=$(LC_ALL=C TZ=UTC0 date)
	T=$(LC_ALL=C TZ=UTC0 date -d "$A")
	Z=$(unset TZ; LANG=C date -d "$A")
	msg_notice "Local time is now:      ${Z}"
	msg_notice "Universal Time is now:  ${T}"
}	# end config_tz


setup_tz() {
	local T=${1:-${TIME_ZONE}}

	[ -f "/usr/share/zoneinfo/${T}" ] || {
		msg_error "The requested timezone does not exists: ${T}"
	}

	# verify needed packages
	pkg_require dbus

	cmd timedatectl set-timezone "${T}"
	cmd timedatectl set-ntp on

	msg_info "Configuration of timezone completed!"
	echo -e "$(cmd timedatectl)"
}	# end setup_tz
