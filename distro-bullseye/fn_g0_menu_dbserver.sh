# ------------------------------------------------------------------------------
# install the db server mariadb-server-10.5 (fully compatible with mysql)
# https://reposcope.com/package/mariadb-server
# ------------------------------------------------------------------------------

Install.mariadb() {
	local d p="mariadb-server"

	# abort if mariadb is already installed
	Pkg.installed "$p" && {
		Msg.warn "$p is already installed..."
		return
	}

	# install required packages
	Msg.info "Installing $p for ${ENV_os}..."
	Pkg.install mariadb-client mariadb-server

	Msg.info "Configuring $p"

	# higher limits to prevent error: Error in accept: Too many open files
	d=/etc/security
	grep -q '^mysql' $d/limits.conf || {
		echo -e "mysql soft nofile 65535\nmysql hard nofile 65535" >> $d/limits.conf
	}
	mkdir -p /etc/systemd/system/mariadb.service.d && d="$_"
	[ -s $d/limits.conf ] || File.into $d mysql/limits.conf

	# install a custom configuration file
	File.into /etc/mysql/mariadb.conf.d mysql/60-server.cnf

	# lite version of mysql_secure_installation
	cmd mysql <<-EOF
		ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_rootpw';
		DELETE FROM mysql.user WHERE User='';
		DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost','127.0.0.1','::1');
		DROP DATABASE IF EXISTS test;
		DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
		FLUSH PRIVILEGES;
		EOF

	cmd systemctl daemon-reload
	cmd systemctl restart mysql
	Msg.info "Installation of $p completed!"
}	# end Install.mariadb


Menu.dbserver() {
	# metadata for OS.menu entries
	__section='Main applications'
	__summary="the DB server MariaDB, root pw stored in $(Dye.fg.white \~/.my.cnf)"

	# abort if "Menu.deps" was not executed
	Deps.performed || return

	# save the root password of the DB in ~/.my.cnf
	# it also set the variable DB_rootpw
	[ -n "$DB_rootpw" ] || DB.rootpw

	# install the database server (mariadb)
	cmd Install.mariadb
}	# end Menu.dbserver
