# ------------------------------------------------------------------------------
# customize timezone & localtime
# ------------------------------------------------------------------------------

setup_tz() {
	local T=${1:-${TIME_ZONE}}

	[ -f "/usr/share/zoneinfo/${T}" ] || {
		Msg.error "The requested timezone does not exists: ${T}"
	}

	# verify needed packages
	Pkg.requires dbus

	cmd timedatectl set-timezone "${T}"
	cmd timedatectl set-ntp true

	Msg.info "Configuration of timezone completed!"
	echo -e "$(cmd timedatectl)"
}	# end setup_tz
