# ------------------------------------------------------------------------------
# install roundcube webmail
# Roundcube 1.0.7 requirements: php5 php-pear php5-mysql php5-mcrypt php5-intl
# Roundcube 1.1.3 requirements: php-mail-mime php-net-smtp
# Roundcube 1.3.3 requirements: php5-ldap
# Roundcube 1.3.6: 2018-06-24
# Roundcube 1.3.7: 2018-10-21
# Roundcube 1.3.8: 2019-02-02
# Roundcube 1.3.9: 2019-04-23
# Roundcube 1.3.10: 2019-10-06
# Roundcube 1.3.13: 2020-07-05
# Roundcube 1.3.15: 2020-09-21 security update
# ------------------------------------------------------------------------------

menu_roundcube() {
	local p d=/var/www/roundcube v=1.3.15	# version to install

	# test if not already installed
	[ -s "${d}/index.php" ] && {
		Msg.warn "Roundcube is already installed..."
		return
	}

	Msg.info "Installing Roundcube ${v}..."
	mkdir -p ${d}
	p=$(menu_password 32)					# random password

	# install requirements
	pkg_require php5 php-pear php5-mysqlnd php5-mcrypt php5-intl php-mail-mime \
		php-net-smtp php5-ldap

	# download the right version
	v=https://github.com/roundcube/roundcubemail/releases/download/${v}/roundcubemail-${v}-complete.tar.gz
	cd /tmp
	down_load "${v}" roundcubemail.tar.gz
	tar xzf roundcubemail.tar.gz
	cd roundcubemail-*
	mv -t "${d}" bin config logs plugins program skins temp vendor .htaccess index*

	# instruct search engines to not index our webmail
	echo -e "User-agent: *\nDisallow: /" > ${d}/robots.txt

	# creating a new database, then populate it from file
	create_database "roundcube" "roundcube" "${p}"
	cmd mysql 'roundcube' < SQL/mysql.initial.sql

	# install & configure plugins for ISPConfig3
	cd /tmp
	down_load https://github.com/w2c/ispconfig3_roundcube/archive/master.zip plugins.zip
	unzip -qo plugins*
	mv ispconfig3*/ispconfig3_* ${d}/plugins/
	# install the config file
	cd ${d}/plugins/ispconfig3_account/config
	do_copy roundcube/config.inc.php.plugin config.inc.php
	sed -i "s|RPW|${p}|;s|://127.0.0.1/ispconfig|s://127.0.0.1:8080|" config.inc.php

	# install & configure contextmenu plugin
	cd /tmp
	down_load https://github.com/JohnDoh/roundcube-contextmenu/archive/master.zip contextmenu.zip
	unzip -qo contextmenu*
	cd roundcube-contextmenu*
	mkdir -p ${d}/plugins/contextmenu
	mv -t ${d}/plugins/contextmenu localization skins contextmenu*

	# install the config file
	cd ${d}/config
	v=$(menu_password 24 1)	# strong password
	do_copy roundcube/config.inc.php.roundcube config.inc.php
	sed -i "s|RPW|${p}|;s|DESKEY|${v}|" config.inc.php

	# install into sites-available of apache2
	[ -d /etc/apache2 ] && {
		cd /etc/apache2
		copy_to sites-available roundcube/roundcube.conf
		[ -L sites-enabled/080-roundcube.conf ] || {
			ln -s ../sites-available/roundcube.conf sites-enabled/080-roundcube.conf
		}
	}

	# set permissions
	cd ${d}
	chown -R 0:0 .
	chown -R 33:0 logs temp # set user www-data
	chmod -R 400 .
	chmod -R u+rwX,go+rX,go-w .

	# add the remote_soap_user into ISPConfig3 database, if ISPConfig3 is installed
	[ -d /usr/local/ispconfig ] && {
		sed -e "s|RPW|${p}|" <<'EOF' | mysql
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
		cat <<EOF >> /etc/crontab

# ROUNDCUBE daily db cleaning
18 23 * * * root php ${d}/bin/cleandb.sh > /dev/null 2>&1
EOF
	}

	# activating some modules of apache2 then reload its configurations
	a2enmod deflate expires headers
	svc_evoke apache2 restart
}	# end menu_roundcube
