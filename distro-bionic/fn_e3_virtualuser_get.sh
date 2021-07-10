# ------------------------------------------------------------------------------
# add a new user "vmail" or use the existing "postfix"
# ------------------------------------------------------------------------------

virtualuser_get() {
	# get user uid & gid
	if [ $(cmd id -u postfix) -ge 1 ]
	then
		VIRTUAL_USER_UID=$(cmd id -u postfix)
		VIRTUAL_USER_GID=$(cmd id -g postfix)
		Msg.info "Using postfix as user vmail: UID=${VIRTUAL_USER_UID}, GID=${VIRTUAL_USER_GID}"

	else
		# add user vmail
		useradd -r -u 150 -g mail -d /home/vmail -s /sbin/nologin -c "Virtual Mailbox" vmail

		mkdir -p /home/vmail
		chown -R vmail:mail /home/vmail
		chmod -R 700 /home/vmail

		VIRTUAL_USER_UID=$(cmd id -u vmail)
		VIRTUAL_USER_GID=$(cmd id -g mail)
		Msg.info "Creating virtual user completed: UID=${VIRTUAL_USER_UID}, GID=${VIRTUAL_USER_GID}"
	fi;
}	# end virtualuser_get
