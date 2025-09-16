# ------------------------------------------------------------------------------
# old style I/O test to perform on server, require coreutils
# ------------------------------------------------------------------------------

IO.extest() {
	# classic disk I/O test
	Msg.info "Performing classic I/O test..."
	dd if=/dev/zero of=~/tmpf bs=64k count=16k conv=fdatasync && rm -rf ~/tmpf
}	# end IO.extest


IO.test() {
	# run the real test, discovering options to add
	local t=/root/iotest.$$
	local o="if=/dev/zero of=$t bs=64k count=16k conv=fdatasync"

	# check if status=progress is supported
	[[ $(dd --help 2>&1) == *"'progress'"* ]] && o+=" status=progress"

	# try oflag=direct if supported by filesystem
	if dd if=/dev/zero of=$t bs=4k count=1 oflag=direct conv=fdatasync 2>/dev/null; then
		o+=" oflag=direct"
	fi

	dd $o && rm -f "$t"
}	# end IO.test


Menu.iotest() {
	# metadata for OS.menu entries
	__section='Standalone utilities'
	__summary="perform simple classic I/O test on the disk"

	# classic disk I/O test
	Msg.info "Performing classic I/O test..."
	IO.test
}	# end Menu.iotest
