# ------------------------------------------------------------------------------
# install one single database
# ------------------------------------------------------------------------------

create_database() {
	# creating a new database
	# $1 database name
	# $2 username
	# $3 password
	local UN PW K DB="${1-myuserdb}"

	# detect an available database name
	[ -d "/var/lib/mysql/${DB}" ] && for K in {1..99}; do
		[ -d "/var/lib/mysql/${DB}_${K}" ] || { DB="${DB}_${K}"; break; }
	done

	UN="${2-${DB}}"					# username as db name, if not provided
	PW="${3-$(menu_password 16)}"	# random pw length 16, if not provided

	# creating the new database & the user
#	cmd mysqladmin create "${DB}"
	cmd mysql <<< "CREATE DATABASE ${DB};"
	cmd mysql <<< "GRANT ALL ON ${DB}.* TO ${UN}@localhost IDENTIFIED BY '${PW}';"
#	cmd mysql <<< "REVOKE ALL ON ${DB}.* FROM ${UN}@localhost;"
#	cmd mysql <<< "DROP USER ${UN}@localhost;"

	# appending info in ~
	echo -e "[${DB}]\nusername = ${UN}\npassword = ${PW}\n" >> ~/.dbdata.txt

	msg_info "Creation of the new database '${DB}' completed!"
}	# end create_database
