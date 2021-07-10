# ------------------------------------------------------------------------------
# install adminer, as an alternative to phpmyadmin
# ------------------------------------------------------------------------------

install_adminer() {
	# set: root directory & version
	local URL ADM DIRE=/var/www/myadminer VER="4.3.1"

	[ -s "${DIRE}/index.php" ] && {
		Msg.warn "adminer-${VER} is already installed..."
		return
	}

	Msg.info "Installing adminer-${VER}..."

	# create directory if it not exists (with -p)
	mkdir -p ${DIRE} && cd "$_"

	# get the plugins folder
	URL=https://github.com/vrana/adminer/releases/download/v${VER}
	down_load "${URL}/adminer-${VER}.zip" "adminer-${VER}.zip"
	# some cleanup
	unzip -qo "adminer-${VER}.zip"
	mv ./adminer-${VER}/plugins ./
	rm -rf ./adminer-${VER}*

	# download script
	ADM="adminer-${VER}-mysql-en.php"
	down_load "${URL}/${ADM}" "${ADM}"

	# install the index.php file
	copy_to . adminer/index.php
	sed -i "s|FILE|${ADM}|" index.php

	# install css file & tables-filter plugin
	copy_to . adminer/adminer.css
	copy_to plugins adminer/tables-filter.php

	# install the virtualhost file for apache2
	cd /etc/apache2
	copy_to sites-available adminer/adminer.conf
	[ -L sites-enabled/080-adminer.conf ] || {
		ln -s ../sites-available/adminer.conf sites-enabled/080-adminer.conf
		svc_evoke apache2 restart
	}

	Msg.info "Installation of adminer-${VER} completed!"
}	# end install_adminer
