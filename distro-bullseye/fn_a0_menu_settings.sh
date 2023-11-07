# ------------------------------------------------------------------------------
# add a swap file on KVM or DEDI systems that dont have one
# ------------------------------------------------------------------------------

Menu.settings() {
	# write some settings on file
	local f=settings.conf

	# discover file
	[ -s "$f" ] || {
		Msg.warn "The file $f is missing..."
		return
	}

	Msg.info "A swap file of $z was implemented in '$f' permanently!"
}	# end Menu.settings




