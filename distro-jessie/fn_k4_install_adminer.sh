# ------------------------------------------------------------------------------
# install adminer, as an alternative to phpmyadmin
# ------------------------------------------------------------------------------

install_adminer() {
	# set: root directory & version
	local u a d=/var/www/myadminer v="4.3.1"

	[ -s "$d/index.php" ] && {
		Msg.warn "adminer-$v is already installed..."
		return
	}

	Msg.info "Installing adminer-${v}..."

	# create directory if it not exists (with -p)
	mkdir -p $d && cd "$_"

	# get the plugins folder
	u=https://github.com/vrana/adminer/releases/download/v${v}
	File.download "$u/adminer-${v}.zip" "adminer-${v}.zip"
	# some cleanup
	unzip -qo "adminer-${v}.zip"
	mv ./adminer-$v/plugins ./
	rm -rf ./adminer-${v}*

	# download script
	a="adminer-${v}-mysql-en.php"
	File.download "$u/$a" "$a"

	# install the index.php file
	File.into . adminer/index.php
	sed -i "s|FILE|$a|" index.php

	# install css file & tables-filter plugin
	File.into . adminer/adminer.css
	File.into plugins adminer/tables-filter.php

	# install the virtualhost file for apache2
	cd /etc/apache2
	File.into sites-available adminer/adminer.conf
	[ -L sites-enabled/080-adminer.conf ] || {
		ln -s ../sites-available/adminer.conf sites-enabled/080-adminer.conf
		svc_evoke apache2 restart
	}

	Msg.info "Installation of adminer-$v completed!"
}	# end install_adminer
