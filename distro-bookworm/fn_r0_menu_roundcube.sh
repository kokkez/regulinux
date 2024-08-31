# ------------------------------------------------------------------------------
# install roundcube webmail
# Roundcube 1.4.15: 2024-08-31
# Roundcube 1.5.8:  2024-08-31
# ------------------------------------------------------------------------------

RC.grab() {
	# download and install the webmail
	# $1 - version to install
	# $2 - path to roundcube root
	mkdir -p $2

	# download the wanted version
	File.download \
		https://github.com/roundcube/roundcubemail/releases/download/$1/roundcubemail-$1-complete.tar.gz \
		~/roundcubemail.tar.gz
	tar xzf roundcubemail.tar.gz
	cd roundcubemail-*
	mv -ft "$2" bin config logs plugins program skins temp vendor .htaccess index*

	# try to instruct search engines to not index our webmail
	echo -e "User-agent: *\nDisallow: /" > "$2/robots.txt"

	# install crontab to keep the database cleaned
	[ -s /etc/crontab ] && grep -q 'ROUNDCUBE' /etc/crontab || {
		File.backup /etc/crontab
		cat >> /etc/crontab <<- EOF

			# ROUNDCUBE daily db cleaning
			18 23 * * * root php $2/bin/cleandb.sh > /dev/null 2>&1
			EOF
	}
}	# end RC.grab


RC.plugins() {
	# download and install some plugins
	# $1 - password for roundcube database
	# $2 - path to roundcube root

	# plugins for ISPConfig3
	Msg.info "Downloading roundcube/ispconfig3 plugins..."
	File.download \
		https://github.com/w2c/ispconfig3_roundcube/archive/master.zip \
		~/plugins.zip
	unzip -qo ~/plugins.zip
	mv -f ispconfig3*/ispconfig3_* "$2/plugins/"
	# install the config file
	cd $2/plugins/ispconfig3_account/config
	File.place roundcube/config.inc.php.plugin config.inc.php
	sed -i config.inc.php -e "s|RPW|$1|;s|://127.0.0.1/ispconfig|s://127.0.0.1:8080|"
	rm -rf ~/plugins.zip ~/ispconfig3*/

	# contextmenu plugin
	Msg.info "Downloading roundcube/contextmenu plugin..."
	File.download \
		https://github.com/JohnDoh/roundcube-contextmenu/archive/master.zip \
		~/contextmenu.zip
	unzip -qo ~/contextmenu.zip
	cd roundcube-contextmenu*
	mkdir -p $2/plugins/contextmenu
	mv -ft $2/plugins/contextmenu localization skins contextmenu*
	rm -rf ~/contextmenu.zip ~/roundcube-contextmenu*/

	# install the main config file
	cd $2/config
	File.place roundcube/config.inc.php.roundcube config.inc.php
	sed -i config.inc.php \
		-e "s|RPW|$1|;s|DESKEY|$(Menu.password 24 1)|"	# strong password
}	# end RC.plugins


RC.database() {
	# install new db & add remote user to ispconfig
	# $1 - password for roundcube database

	# creating a new database, then populate it from file
	Create.database "roundcube" "roundcube" "$1"
	cmd mysql 'roundcube' < ~/roundcubemail-*/SQL/mysql.initial.sql

	# if ispconfig is installed, add the remote user into the db
	ISPConfig.installed && {
		sed -e "s|RPW|$1|" <<- 'EOF' | mysql
			USE dbispconfig;
			INSERT INTO remote_user (
			sys_userid,
			sys_groupid,
			sys_perm_user,
			sys_perm_group,
			sys_perm_other,
			remote_username,
			remote_password,
			remote_functions
			) SELECT * FROM (
			SELECT
			'1' a,
			'1' b,
			'riud' c,
			'riud' d,
			'' e,
			'roundcube' f,
			MD5('RPW') g,
			'server_get,get_function_list,client_templates_get_all,server_get_serverid_by_ip,server_ip_get,server_ip_add,server_ip_update,server_ip_delete;client_get_all,client_get,client_add,client_update,client_delete,client_get_sites_by_user,client_get_by_username,client_change_password,client_get_id,client_delete_everything;mail_user_get,mail_user_add,mail_user_update,mail_user_delete;mail_alias_get,mail_alias_add,mail_alias_update,mail_alias_delete;mail_spamfilter_user_get,mail_spamfilter_user_add,mail_spamfilter_user_update,mail_spamfilter_user_delete;mail_policy_get,mail_policy_add,mail_policy_update,mail_policy_delete;mail_fetchmail_get,mail_fetchmail_add,mail_fetchmail_update,mail_fetchmail_delete;mail_spamfilter_whitelist_get,mail_spamfilter_whitelist_add,mail_spamfilter_whitelist_update,mail_spamfilter_whitelist_delete;mail_spamfilter_blacklist_get,mail_spamfilter_blacklist_add,mail_spamfilter_blacklist_update,mail_spamfilter_blacklist_delete;mail_user_filter_get,mail_user_filter_add,mail_user_filter_update,mail_user_filter_delete' h
			) t WHERE NOT EXISTS (
			SELECT 1 FROM remote_user WHERE remote_username = 'roundcube'
			) LIMIT 1;
			EOF
	}
}	# end RC.database


Menu.roundcube() {
	local p d v=1.4.15		# version to install
	d=/var/www/roundcube	# directory root

	# test if roundcube is already installed
	[ -s "$d/index.php" ] && {
		Msg.warn "Roundcube $v is already installed in ${d}..."
		return
	}

	# test if running mariadb
	systemctl is-active -q mariadb || {
		Msg.warn "Roundcube $v require a running mariadb server..."
		return
	}

	Msg.info "Downloading Roundcube $v..."
	RC.grab "$v" "$d"

	p=$(Menu.password 32)	# random password
	RC.plugins "$p" "$d"
	RC.database "$p"

	# install the configuration file for nginx webserver
	if systemctl is-active -q nginx; then
		File.into /etc/nginx/snippets roundcube/roundcube-nginx.conf
		systemctl restart nginx

	# ... or for apache2 webserver
	elif systemctl is-active -q apache2; then
		cd /etc/apache2/sites-enabled
		File.islink '080-roundcube.conf' || {
			File.into ../sites-available roundcube/roundcube.conf
			ln -nfs ../sites-available/roundcube.conf '080-roundcube.conf'
		}
		# activating some modules of apache2 then reload its configurations
		cmd a2enmod deflate expires headers
		systemctl restart apache2
	fi;

	# finishing, set permissions, remove SQL folder
	cd $d
	chown -R 0:0 .
	chown -R 33:0 logs temp		# set user www-data
	chmod -R 400 .
	chmod -R u+rwX,go+rX,go-w .
	rm -rf ~/*roundcube*
	cd ~

	Msg.info "Installation of Roundcube $v completed!"
}	# end Menu.roundcube
