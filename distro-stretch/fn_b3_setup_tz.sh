# ------------------------------------------------------------------------------
# customize timezone & localtime
# ------------------------------------------------------------------------------

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
