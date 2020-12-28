# ------------------------------------------------------------------------------
# install the database server mariadb (fully compatible with mysql)
# ------------------------------------------------------------------------------

install_server_mariadb() {
	# debian 9 stretch install mariadb-server-10.1
	local PKG="mariadb-server"

	is_installed "${PKG}" || {
		msg_info "Installing ${PKG}..."
		pkg_install mariadb-client mariadb-server
	}

	msg_info "Configuring ${PKG}"

	# set debian passwords
	cd /etc/mysql
	sed -ri "s/^pass.*/password = ${DB_ROOTPW}/g" debian.cnf

	# higher limits to prevent error: Error in accept: Too many open files
	cd /etc/security
	grep -q '^mysql' limits.conf || {
		echo -e "mysql soft nofile 65535\nmysql hard nofile 65535" >> limits.conf
	}
	mkdir -p /etc/systemd/system/mariadb.service.d && cd "$_"
	[ -s limits.conf ] || copy_to . mysql/limits.conf

	# install a custom configuration file
	copy_to /etc/mysql/mariadb.conf.d mysql/60-server.cnf

	# lite version of mysql_secure_installation
	cmd mysql <<EOF
UPDATE mysql.user SET Password=PASSWORD('${DB_ROOTPW}') WHERE User='root';
UPDATE mysql.user SET plugin='' WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost','127.0.0.1','::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

	cmd systemctl daemon-reload
	cmd systemctl restart mysql
	msg_info "Installation of ${PKG} completed!"
}	# end install_server_mariadb
