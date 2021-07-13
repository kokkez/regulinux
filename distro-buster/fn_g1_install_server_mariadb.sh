# ------------------------------------------------------------------------------
# install mariadb-server-10.3 (fully compatible with mysql)
# https://reposcope.com/package/mariadb-server
# ------------------------------------------------------------------------------

install_server_mariadb() {
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

	# set debian passwords
	sed -ri /etc/mysql/debian.cnf \
		-e "s/^pass.*/password = $DB_ROOTPW/g"

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
	cmd mysql <<EOF
UPDATE mysql.user SET Password=PASSWORD('$DB_ROOTPW') WHERE User='root';
UPDATE mysql.user SET plugin='mysql_native_password' WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost','127.0.0.1','::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

	cmd systemctl daemon-reload
	cmd systemctl restart mysql
	Msg.info "Installation of $p completed!"
}	# end install_server_mariadb
