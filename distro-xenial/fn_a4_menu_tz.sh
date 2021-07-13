# ------------------------------------------------------------------------------
# set the timezone & the localtime
# ------------------------------------------------------------------------------

Menu.tz() {
	local a z t=${1:-$TIME_ZONE}

	[ -f "/usr/share/zoneinfo/$t" ] || {
		Msg.error "The requested timezone does not exists: $t"
	}

	# split into variables
	a=${t%%/*} z=${t#*/}
	Msg.info "Setup timezone as AREA: '$a', ZONE: '$z'"

	# backup old first, then get the new from zoneinfo file
	File.backup /etc/localtime
	rm -f /etc/localtime
	cp "/usr/share/zoneinfo/$t" /etc/localtime
	echo "$t" > /etc/timezone		# also write in /etc/timezone

	# preseed tzdata, then reconfigure
	debconf-set-selections <<EOF
tzdata tzdata/Areas select $a
tzdata tzdata/Zones/$a select $z
EOF
	dpkg-reconfigure -f noninteractive tzdata > /dev/null 2>&1

	# Show the new setting on the shell
	a=$(LC_ALL=C TZ=UTC0 date)
	t=$(LC_ALL=C TZ=UTC0 date -d "$a")
	z=$(unset TZ; LANG=C date -d "$a")
	Msg.debug "Local time is now:      $z"
	Msg.debug "Universal Time is now:  $t"
}	# end Menu.tz
