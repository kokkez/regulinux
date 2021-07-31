# ------------------------------------------------------------------------------
# customize timezone & localtime
# ------------------------------------------------------------------------------

setup_tz() {
	local t=${1:-$TIME_ZONE}

	[ -f "/usr/share/zoneinfo/$t" ] || {
		Msg.error "The requested timezone does not exists: $t"
	}

	# install needed packages, if missing
	Pkg.requires dbus

	cmd timedatectl set-timezone "$t"
	cmd timedatectl set-ntp true

	Msg.info "Configuration of timezone completed!"
	echo -e "$(cmd timedatectl)"
}	# end setup_tz
