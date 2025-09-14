# ------------------------------------------------------------------------------
# install the database server
# ------------------------------------------------------------------------------

Menu.dbserver() {
	# metadata for OS.menu entries
	__section='Main applications'
	__summary="the DB server MariaDB, root pw stored in $(Dye.fg.white \~/.my.cnf)"

	# $1: target system to build, optional
	TARGET="${1:-$TARGET}"

	# abort if "Menu.deps" was not executed
	Deps.performed || return

	# save the root password of the DB in ~/.my.cnf
	# it also set the variable DB_rootpw
	[ -n "$DB_rootpw" ] || DB.rootpw

	# install the database server (mariadb)
	cmd install_server_mariadb
}	# end Menu.dbserver
