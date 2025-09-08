# ------------------------------------------------------------------------------
# create one single empty sql database, then save infos in ~/.dbdata.txt
# ------------------------------------------------------------------------------

Create.database() {
	# creating a new database
	# $1 database name
	# $2 username, optional, db name will be used
	# $3 password, optional, will be generated a random pw, length 16
	local u p k d="${1:-myuserdb}"

	# detect an available database name
	[ -d "/var/lib/mysql/$d" ] && {
		for k in {1..99}; do
			[ -d "/var/lib/mysql/${d}_$k" ] || { d="${d}_$k"; break; }
		done
	}

	u="${2:-$d}"					# username as db name, if not provided
	p="${3:-$( Pw.generate 16 )}"	# random pw length 16, if not provided

	# creating the new database & the user
#	cmd mysqladmin create "$d"
	cmd mysql <<< "CREATE DATABASE $d;"
#	cmd mysql <<< "GRANT ALL ON $d.* TO $u@localhost IDENTIFIED BY '$p';"
	cmd mysql <<- EOF
		CREATE USER IF NOT EXISTS '$u'@'localhost' IDENTIFIED BY '$p';
		ALTER USER '$u'@'localhost' IDENTIFIED BY '$p';
		GRANT ALL ON $d.* TO '$u'@'localhost';
		FLUSH PRIVILEGES;
		EOF
#	cmd mysql <<< "REVOKE ALL ON $d.* FROM $u@localhost;"
#	cmd mysql <<< "DROP USER $u@localhost;"

	# appending info in ~ updating password if section exists
	k=~/.dbdata.txt
	if grep -qF "[$d]" "$k"; then
		awk -v d="[$d]" -v p="$p" '
			$0==d {f=1; print; next}
			/^\[.*\]/ {f=0}
			f && /^password =/ {$0="password = " p}
			{print}
		' $k > $k.tmp && mv $k.tmp $k
	else
		echo -e "[$d]\nusername = $u\npassword = $p\n" >> $k
	fi

	Msg.info "Creation of the new database '$d' completed!"
}	# end Create.database
