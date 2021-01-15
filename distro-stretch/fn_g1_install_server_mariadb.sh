# ------------------------------------------------------------------------------
# install mariadb-server-10.1 (fully compatible with mysql)
# https://reposcope.com/package/mariadb-server
# ------------------------------------------------------------------------------

install_server_mariadb() {
	local K="mariadb-server"

	# abort if mariadb is already installed
	is_installed "${K}" && {
		msg_alert "${K} is already installed..."
		return
	}

	# install required packages
	msg_info "Installing ${K}..."
	pkg_install mariadb-client mariadb-server

	msg_info "Configuring ${K}"

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
	msg_info "Installation of ${K} completed!"
}	# end install_server_mariadb
