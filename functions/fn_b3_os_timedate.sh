# ------------------------------------------------------------------------------
# customize timezone & localtime
# ------------------------------------------------------------------------------

OS.timedate() {
	local t=${1:-$TIME_ZONE}

	[ -f "/usr/share/zoneinfo/$t" ] || {
		Msg.error "The requested timezone does not exists: $t"
	}

	# install needed packages, if missing
	Pkg.requires dbus systemd-timesyncd

	timedatectl set-timezone "$t"
	timedatectl set-ntp true

	Msg.info "Configuration of timezone completed!"
	timedatectl | sed 's|^|> |'
}	# end OS.timedate
