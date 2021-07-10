# ------------------------------------------------------------------------------
# set the timezone & the localtime
# ------------------------------------------------------------------------------

menu_tz() {
	local TIZO=${1:-${TIME_ZONE}}

	[ -f "/usr/share/zoneinfo/${TIZO}" ] || {
		Msg.error "The requested timezone does not exists: ${TIZO}"
	}

	# split into variables
	local AREA=${TIZO%%/*} ZONE=${TIZO#*/}
	Msg.info "Setup timezone as AREA: '${AREA}', ZONE: '${ZONE}'"

	# backup old first, then get the new from zoneinfo file
	backup_file /etc/localtime
	rm -f /etc/localtime
	cp "/usr/share/zoneinfo/${TIZO}" /etc/localtime
	echo "${TIZO}" > /etc/timezone		# also write in /etc/timezone

	# preseed tzdata, then reconfigure
	debconf-set-selections <<EOF
tzdata tzdata/Areas select ${AREA}
tzdata tzdata/Zones/${AREA} select ${ZONE}
EOF
	dpkg-reconfigure -f noninteractive tzdata > /dev/null 2>&1

	# Show the new setting in concole
	TZBase=$(LC_ALL=C TZ=UTC0 date)
	UTdate=$(LC_ALL=C TZ=UTC0 date -d "$TZBase")
	TZdate=$(unset TZ; LANG=C date -d "$TZBase")
	Msg.debug "Local time is now:      ${TZdate}"
	Msg.debug "Universal Time is now:  ${UTdate}"
}	# end menu_tz
