# ------------------------------------------------------------------------------
# install the database server mysql
# ------------------------------------------------------------------------------

install_server_mysql() {
	# debian 8 jessie install mysql-server-5.5
	local PKG="mysql-server-5.5"

	is_installed "${PKG}" || {
		Msg.info "Installing ${PKG}..."

		# preseed mysql-server
		debconf-set-selections <<EOF
${PKG} mysql-server/root_password password ${DB_ROOTPW}
${PKG} mysql-server/root_password_again password ${DB_ROOTPW}
EOF
		pkg_install bsdutils mysql-client mysql-server
	}

	Msg.info "Configuring ${PKG}"
	cd /etc/mysql

	# allow MySQL to listen on all interfaces
	# correct some deprecated keys (http://kb.sp.parallels.com/en/120461)
	backup_file my.cnf
	sed -ri my.cnf \
		-e "s/^(bind-address)/#\1/" \
		-e "s/^(key_buffer)\s+/\1_size     /" \
		-e "s/^(myisam-recover)\s+/\1-options  /"

	# install a custom configuration to disable InnoDB
	> /var/log/mysql/slow-queries.log
	copy_to conf.d mysql/custom.cnf

	# lite version of mysql_secure_installation
#	UPDATE mysql.user SET Password=PASSWORD('${DB_ROOTPW}') WHERE User='root';
	cmd mysql <<EOF
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost','127.0.0.1','::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

	svc_evoke mysql restart
	Msg.info "Installation of ${PKG} completed!"
}	# end install_server_mysql
