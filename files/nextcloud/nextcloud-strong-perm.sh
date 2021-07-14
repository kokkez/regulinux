#!/bin/bash

#cd /var/www
#chown -R 33:0 nextcloud
#rm -rf nextcloud
#wget https://download.nextcloud.com/server/releases/nextcloud-10.0.5.zip
#unzip -qo nextcloud-*.zip
#bash ~/nextcloud-relaxed-perm.sh
#sudo -u www-data php /var/www/nextcloud/occ upgrade
#sudo -u www-data php /var/www/nextcloud/occ maintenance:mode --off
#sudo -u www-data php /var/www/nextcloud/occ files:scan --all
#bash ~/nextcloud-strong-perm.sh
#invoke-rc.d apache2 restart

ocpath='/var/www/nextcloud'
htuser='www-data'
htgroup='www-data'
rootuser='root'

printf "Creating possible missing Directories\n"
mkdir -p $ocpath/data
#mkdir -p $ocpath/assets
mkdir -p $ocpath/updater

printf "chmod Files and Directories\n"
find ${ocpath}/ -type f -print0 | xargs -0 chmod 0640
find ${ocpath}/ -type d -print0 | xargs -0 chmod 0750

printf "chown Directories\n"
chown -R ${rootuser}:${htgroup} ${ocpath}/
chown -R ${htuser}:${htgroup} ${ocpath}/apps/
chown -R ${htuser}:${htgroup} ${ocpath}/assets/
chown -R ${htuser}:${htgroup} ${ocpath}/config/
chown -R ${htuser}:${htgroup} ${ocpath}/data/
chown -R ${htuser}:${htgroup} ${ocpath}/themes/
chown -R ${htuser}:${htgroup} ${ocpath}/updater/

chmod +x ${ocpath}/occ

printf "chmod/chown .htaccess\n"
if [ -f ${ocpath}/.htaccess ]
	then
	chmod 0644 ${ocpath}/.htaccess
	chown ${rootuser}:${htgroup} ${ocpath}/.htaccess
fi
if [ -f ${ocpath}/data/.htaccess ]
	then
	chmod 0644 ${ocpath}/data/.htaccess
	chown ${rootuser}:${htgroup} ${ocpath}/data/.htaccess
fi
