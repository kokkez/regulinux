# ------------------------------------------------------------------------------
# add a new user "vmail" or use the existing "postfix"
# ------------------------------------------------------------------------------

User.vmail.set() {
	# setup the user vmail for postfix
	# if missing it creates a new user with related group
	local d u=$(cmd id -u postfix)

	[ $u -ge 1 ] && {
		Msg.info "Using postfix as user vmail: UID=$u, GID=$( cmd id -g postfix )"
	} || {
		d=/home/vmail
		# add user vmail
		cmd useradd -r -u 150 -g mail -d $d \
			-s /sbin/nologin \
			-c "Virtual Mailbox" \
			vmail

		mkdir -p $d
		chown -R vmail:mail $d
		chmod -R 700 $d

		Msg.info "Creating virtual user completed: UID=$( cmd id -u vmail ), GID=$( cmd id -g mail )"
	}
}	# end User.vmail.set
