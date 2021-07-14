# ------------------------------------------------------------------------------
# read the database root password from ~/.my.cnf & set DB_rootpw
# ------------------------------------------------------------------------------

DB.rootpw() {
	# read the database root password from ~/.my.cnf
	[ -s ~/.my.cnf ] || {
		# write a random password if it is not already saved
		echo -e "[client]\nuser=root\npassword=$( Menu.password )" > ~/.my.cnf
		chmod 600 ~/.my.cnf
	}
	DB_rootpw="$(cmd awk '/^pass/' ~/.my.cnf)"
	DB_rootpw=$(cmd xargs <<< "${DB_rootpw#*=}")
}	# end DB.rootpw
