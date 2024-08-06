# ------------------------------------------------------------------------------
# install the database server
# ------------------------------------------------------------------------------

Menu.dbserver() {
	# $1: target system to build, optional
	TARGET="${1:-$TARGET}"

	# abort if "Menu.deps" was not executed
	Deps.performed || return

	# save the root password of the DB in ~/.my.cnf
	# it also set the variable DB_rootpw
	[ -n "$DB_rootpw" ] || DB.rootpw

	# get the type of database server to install (defaults to mysql)
	cmd install_server_mysql
}	# end Menu.dbserver
