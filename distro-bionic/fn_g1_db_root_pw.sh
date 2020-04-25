# ------------------------------------------------------------------------------
# read the database root password from ~/.my.cnf & set DB_ROOTPW
# ------------------------------------------------------------------------------

db_root_pw() {
	# read the database root password from ~/.my.cnf
	[ -s ~/.my.cnf ] || {
		# write a random password if it is not already saved
		echo -e "[client]\nuser=root\npassword=$(menu_password)" > ~/.my.cnf
		chmod 600 ~/.my.cnf
	}
	DB_ROOTPW="$(cmd awk '/^pass/' ~/.my.cnf)"
	DB_ROOTPW=$(cmd xargs <<< "${DB_ROOTPW#*=}")
}	# end db_root_pw
