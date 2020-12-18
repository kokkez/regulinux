# ------------------------------------------------------------------------------
# install adminer, as an alternative to phpmyadmin
# ------------------------------------------------------------------------------

install_adminer() {
	# set: root directory & version
	local U D=/var/www/myadminer V="4.7.6"

	[ -s "${D}/index.php" ] && {
		msg_alert "adminer-${V} is already installed..."
		return
	}

	msg_info "Installing adminer-${V}..."

	# create directory if it not exists (with -p)
	mkdir -p ${D} && cd "$_"

	# get the plugins folder
	U=https://github.com/vrana/adminer/releases/download/v${V}
	down_load "${U}/adminer-${V}.zip" "adminer-${V}.zip"
	# some cleanup
	unzip -qo "adminer-${V}.zip"
	mv ./adminer-${V}/plugins ./
	rm -rf ./adminer-${V}*

	# download script
	D="adminer-${V}-mysql-en.php"
	down_load "${U}/${D}" "${D}"

	# install the index.php file
	copy_to . adminer/index.php
	sed -i "s|FILE|${D}|" index.php

	# install css file & plugins, from MyDir
	copy_to . adminer/adminer.css
	copy_to plugins adminer/plugins/*

	if [ "${HTTP_SERVER}" = "nginx" ]; then
		# install the virtualhost file for nginx
		cd /etc/nginx
		do_copy "adminer/adminer.nginx" "sites-available/adminer.conf"
		[ -L sites-enabled/080-adminer.conf ] || {
			ln -s ../sites-available/adminer.conf sites-enabled/080-adminer.conf
			svc_evoke nginx restart
		}
	else
		# install the virtualhost file for apache2
		cd /etc/apache2
		copy_to sites-available adminer/adminer.conf
		[ -L sites-enabled/080-adminer.conf ] || {
			ln -s ../sites-available/adminer.conf sites-enabled/080-adminer.conf
			svc_evoke apache2 restart
		}
	fi;

	msg_info "Installation of adminer-${V} completed!"
}	# end install_adminer
