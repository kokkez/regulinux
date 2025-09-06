# ------------------------------------------------------------------------------
# read the database root password from ~/.my.cnf & set DB_rootpw
# ------------------------------------------------------------------------------

DB.rootpw() {
	# no arguments expected
	local p=~/.my.cnf
	# create the file generating a random password, if missing
	[ -s "$p" ] || {
		echo -e "[client]\nuser=root\npassword=$( Pw.generate )" > "$p"
		chmod 600 "$p"
	}
	# read the root password from ~/.my.cnf
#	DB_rootpw=$(cmd awk -F= '/^pass/{print $2}' "$p")
	Config.set "DB_rootpw" $(cmd awk -F= '/^pass/{print $2}' "$p")
}	# end DB.rootpw
