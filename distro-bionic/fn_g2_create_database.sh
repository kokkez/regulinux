# ------------------------------------------------------------------------------
# create one single empty sql database, then save infos in ~/.dbdata.txt
# ------------------------------------------------------------------------------

create_database() {
	# creating a new database
	# $1 database name
	# $2 username
	# $3 password
	local u p k d="${1:-myuserdb}"

	# detect an available database name
	[ -d "/var/lib/mysql/$d" ] && {
		for k in {1..99}; do
			[ -d "/var/lib/mysql/${d}_$k" ] || { d="${d}_$k"; break; }
		done
	}

	u="${2:-$d}"					# username as db name, if not provided
	p="${3:-$( Menu.password 16 )}"	# random pw length 16, if not provided

	# creating the new database & the user
#	cmd mysqladmin create "$d"
	cmd mysql <<< "CREATE DATABASE $d;"
	cmd mysql <<< "GRANT ALL ON $d.* TO $u@localhost IDENTIFIED BY '$p';"
#	cmd mysql <<< "REVOKE ALL ON $d.* FROM $u@localhost;"
#	cmd mysql <<< "DROP USER $u@localhost;"

	# appending info in ~
	echo -e "[$d]\nusername = $u\npassword = $p\n" >> ~/.dbdata.txt

	Msg.info "Creation of the new database '$d' completed!"
}	# end create_database
