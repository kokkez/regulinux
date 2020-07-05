# ------------------------------------------------------------------------------
# install roundcube webmail
# Roundcube 1.4.3:  2020-02-24
# Roundcube 1.4.6:  2020-07-05
# ------------------------------------------------------------------------------

menu_roundcube() {
	local U P D=/var/www/roundcube V=1.4.6 # version to install

	# test if not already installed
	[ -s "${D}/index.php" ] && {
		msg_alert "Roundcube ${V} is already installed..."
		return
	}

	msg_info "Installing Roundcube ${V}..."
	mkdir -p ${D}
	P=$(menu_password 32) # creating a random password

	# download the right version
	U=https://github.com/roundcube/roundcubemail/releases/download/${V}/roundcubemail-${V}-complete.tar.gz
	cd /tmp
	down_load "${U}" roundcubemail.tar.gz
	tar xzf roundcubemail.tar.gz
	cd roundcubemail-*
	mv -t "${D}" bin config logs plugins program skins temp vendor .htaccess index*

	# instruct search engines to not index our webmail
	echo -e "User-agent: *\nDisallow: /" > ${D}/robots.txt

	# creating a new database, then populate it from file
	create_database "roundcube" "roundcube" "${P}"
	cmd mysql 'roundcube' < SQL/mysql.initial.sql

	# install & configure plugins for ISPConfig3
	cd /tmp
	down_load https://github.com/w2c/ispconfig3_roundcube/archive/master.zip plugins.zip
	unzip -qo plugins*
	mv ispconfig3*/ispconfig3_* ${D}/plugins/
	# install the config file
	cd ${D}/plugins/ispconfig3_account/config
	do_copy roundcube/config.inc.php.plugin config.inc.php
	sed -i "s|RPW|${P}|;s|://127.0.0.1/ispconfig|s://127.0.0.1:8080|" config.inc.php

	# install & configure contextmenu plugin
	cd /tmp
	down_load https://github.com/JohnDoh/roundcube-contextmenu/archive/master.zip contextmenu.zip
	unzip -qo contextmenu*
	cd roundcube-contextmenu*
	mkdir -p ${D}/plugins/contextmenu
	mv -t ${D}/plugins/contextmenu localization skins contextmenu*

	# install the config file
	cd ${D}/config
	U=$(menu_password 24 1)	# strong password
	do_copy roundcube/config.inc.php.roundcube config.inc.php
	sed -i "s|RPW|${P}|;s|DESKEY|${U}|" config.inc.php

	# install into sites-available of apache2
	[ -d /etc/apache2 ] && {
		cd /etc/apache2
		copy_to sites-available roundcube/roundcube.conf
		[ -L sites-enabled/080-roundcube.conf ] || {
			ln -s ../sites-available/roundcube.conf sites-enabled/080-roundcube.conf
		}
	}

	# set permissions
	cd ${D}
	chown -R 0:0 .
	chown -R 33:0 logs temp # set user www-data
	chmod -R 400 .
	chmod -R u+rwX,go+rX,go-w .

	# add the remote_soap_user into ISPConfig3 database, if ISPConfig3 is installed
	[ -d /usr/local/ispconfig ] && {
		sed -e "s|RPW|${P}|" <<'EOF' | mysql
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
		backup_file /etc/crontab
		cat >> /etc/crontab <<EOF

# ROUNDCUBE daily db cleaning
18 23 * * * root php ${D}/bin/cleandb.sh > /dev/null 2>&1
EOF
	}

	# activating some modules of apache2 then reload its configurations
	a2enmod deflate expires headers
	svc_evoke apache2 restart
	msg_info "Installation of Roundcube ${V} completed!"
}	# end menu_roundcube
