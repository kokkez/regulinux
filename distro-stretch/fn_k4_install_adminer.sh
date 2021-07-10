# ------------------------------------------------------------------------------
# install adminer, as an alternative to phpmyadmin
# ------------------------------------------------------------------------------

install_adminer() {
	# set: root directory & version
	local U D=/var/www/myadminer V="4.7.8"

	[ -s "${D}/index.php" ] && {
		Msg.warn "adminer-${V} is already installed..."
		return
	}

	Msg.info "Installing adminer-${V}..."

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

	# install css file & plugins
	copy_to . adminer/adminer.css
	copy_to plugins adminer/plugins/*

	# install the configuration file for webserver
	if [ "${HTTP_SERVER}" = "nginx" ]; then
		copy_to /etc/nginx/snippets adminer/adminer-nginx.conf
		cmd systemctl restart nginx
	else
		cd /etc/apache2/sites-enabled
		is_symlink '080-adminer.conf' || {
			copy_to ../sites-available adminer/adminer.conf
			ln -nfs ../sites-available/adminer.conf '080-adminer.conf'
			cmd systemctl restart apache2
		}
	fi;

	Msg.info "Installation of adminer-${V} completed!"
}	# end install_adminer
