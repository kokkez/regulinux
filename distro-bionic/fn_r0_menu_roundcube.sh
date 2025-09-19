# ------------------------------------------------------------------------------
# install roundcube webmail
# Roundcube 1.4.3:  2020-02-24
# Roundcube 1.4.6:  2020-07-05
# Roundcube 1.4.7:  2020-07-20 security update
# Roundcube 1.4.8:  2020-09-21 security update
# Roundcube 1.4.9:  2020-11-04
# Roundcube 1.4.11: 2021-06-20
# Roundcube 1.4.13: 2022-02-19
# ------------------------------------------------------------------------------

Menu.roundcube() {
	# metadata for OS.menu entries
	__exclude='[ -s /var/www/roundcube/index.php ]'
	__section='Others applications'
	__summary="full featured imap web client v1.4.13"

	local u p d=/var/www/roundcube v=1.4.13 # version to install

	# test if not already installed
	[ -s "$d/index.php" ] && {
		Msg.warn "Roundcube $v is already installed..."
		return
	}

	Msg.info "Installing Roundcube ${v}..."
	mkdir -p $d
	p=$( Pw.generate 32 )		# creating a random password

	# download the right version
	u=https://github.com/roundcube/roundcubemail/releases/download/$v/roundcubemail-${v}-complete.tar.gz
	cd /tmp
	File.download "$u" roundcubemail.tar.gz
	tar xzf roundcubemail.tar.gz
	cd roundcubemail-*
	mv -t "$d" bin config logs plugins program skins temp vendor .htaccess index*

	# instruct search engines to not index our webmail
	echo -e "User-agent: *\nDisallow: /" > $d/robots.txt

	# creating a new database, then populate it from file
	Create.database "roundcube" "roundcube" "$p"
	cmd mysql 'roundcube' < SQL/mysql.initial.sql

	# plugins for ISPConfig3
	cd /tmp
	File.download https://github.com/w2c/ispconfig3_roundcube/archive/master.zip plugins.zip
	unzip -qo plugins*
	mv ispconfig3*/ispconfig3_* $d/plugins/
	# install the config file
	cd $d/plugins/ispconfig3_account/config
	File.place roundcube/config.inc.php.plugin config.inc.php
	sed -i config.inc.php -e "s|RPW|$p|;s|://127.0.0.1/ispconfig|s://127.0.0.1:8080|"

	# contextmenu plugin
	cd /tmp
	File.download https://github.com/JohnDoh/roundcube-contextmenu/archive/master.zip contextmenu.zip
	unzip -qo contextmenu*
	cd roundcube-contextmenu*
	mkdir -p $d/plugins/contextmenu
	mv -t $d/plugins/contextmenu localization skins contextmenu*

	# install the config file
	cd $d/config
	u=$( Pw.generate 24 1 )	# strong password
	File.place roundcube/config.inc.php.roundcube config.inc.php
	sed -i config.inc.php -e "s|RPW|$p|;s|DESKEY|$u|"

	# set permissions
	cd $d
	chown -R 0:0 .
	chown -R 33:0 logs temp		# set user www-data
	chmod -R 400 .
	chmod -R u+rwX,go+rX,go-w .

	# if ispconfig is installed, add the remote user into the db
	ISPConfig.installed && {
		sed -e "s|RPW|$p|" <<'EOF' | mysql
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

	# install crontab to keep the database cleaned
	[ -s /etc/crontab ] && grep -q ROUNDCUBE /etc/crontab || {
		File.backup /etc/crontab
		cat >> /etc/crontab <<EOF

# ROUNDCUBE daily db cleaning
18 23 * * * root php $d/bin/cleandb.sh > /dev/null 2>&1
EOF
	}

	# install the configuration file for webserver
	if [ "$HTTP_SERVER" = "nginx" ]; then
		File.into /etc/nginx/snippets roundcube/roundcube-nginx.conf
		cmd systemctl restart nginx
	else
		cd /etc/apache2/sites-enabled
		File.islink '080-roundcube.conf' || {
			File.into ../sites-available roundcube/roundcube.conf
			ln -nfs ../sites-available/roundcube.conf '080-roundcube.conf'
		}
		# activating some modules of apache2 then reload its configurations
		a2enmod deflate expires headers
		cmd systemctl restart apache2
	fi;

	Msg.info "Installation of Roundcube $v completed!"
}	# end Menu.roundcube
