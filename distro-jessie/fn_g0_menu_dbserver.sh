# ------------------------------------------------------------------------------
# install the database server
# ------------------------------------------------------------------------------

Menu.dbserver() {
	# $1: target system to build, optional
	TARGET="${1:-$TARGET}"

	# verify that the system was set up properly
	done_deps || return

	# save the root password of the DB in ~/.my.cnf
	# it also set the variable DB_ROOTPW
	[ -n "$DB_ROOTPW" ] || db_root_pw

	# get the type of database server to install (defaults to mysql)
	cmd install_server_mysql
}	# end Menu.dbserver
