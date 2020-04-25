# ------------------------------------------------------------------------------
# set the timezone & the localtime
# ------------------------------------------------------------------------------

menu_tz() {
	local a z t=${1:-${TIME_ZONE}}

	[ -f "/usr/share/zoneinfo/${t}" ] || {
		msg_error "The requested timezone does not exists: ${t}"
	}

	# split into variables
	a=${t%%/*} z=${t#*/}
	msg_info "Setup timezone as AREA: '${a}', ZONE: '${z}'"

	# backup old first, then get the new from zoneinfo file
	backup_file /etc/localtime
	rm -f /etc/localtime
	cp "/usr/share/zoneinfo/${t}" /etc/localtime
	echo "${t}" > /etc/timezone		# also write in /etc/timezone

	# preseed tzdata, then reconfigure
	debconf-set-selections <<EOF
tzdata tzdata/Areas select ${a}
tzdata tzdata/Zones/${a} select ${z}
EOF
	dpkg-reconfigure -f noninteractive tzdata > /dev/null 2>&1

	# Show the new setting in concole
	TZBase=$(LC_ALL=C TZ=UTC0 date)
	UTdate=$(LC_ALL=C TZ=UTC0 date -d "$TZBase")
	TZdate=$(unset TZ; LANG=C date -d "$TZBase")
	msg_notice "Local time is now:      ${TZdate}"
	msg_notice "Universal Time is now:  ${UTdate}"
}	# end menu_tz
