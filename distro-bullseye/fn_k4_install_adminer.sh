# ------------------------------------------------------------------------------
# install adminer, as an alternative to phpmyadmin
# ------------------------------------------------------------------------------

install_adminer() {
	# set: root directory & version
	local a n u d=/var/www/myadminer v="4.8.1"

	[ -s "$d/index.php" ] && {
		Msg.warn "adminer-$v is already installed..."
		return
	}

	# check what webserver is active
	a=$(cmd systemctl is-active apache2)
	n=$(cmd systemctl is-active nginx)
	[ "$a" = "active" ] || [ "$n" = "active" ] || {
		Msg.warn "No active webservers found for adminer-$v..."
		return
	}

	Msg.info "Installing adminer-${v}..."

	# create directory if it not exists (with -p)
	mkdir -p $d && cd "$_"

	# get the plugins folder
	u=https://github.com/vrana/adminer/releases/download/v$v
	File.download "$u/adminer-${v}.zip" "adminer-${v}.zip"
	# some cleanup
	unzip -qo "adminer-${v}.zip"
	mv ./adminer-${v}/plugins ./
	rm -rf ./adminer-${v}*

	# download script
	d="adminer-${v}-mysql-en.php"
	File.download "$u/$d" "$d"

	# install the index.php file
	File.into . adminer/index.php
	sed -i index.php -e "s|FILE|$d|"

	# install css file & plugins
	File.into . adminer/adminer.css
	File.into plugins adminer/plugins/*

	# install the configuration file for webserver
	if [ "$n" = "active" ]; then
		File.into /etc/nginx/snippets adminer/adminer-nginx.conf
		cmd systemctl restart nginx

	elif [ "$a" = "active" ]; then
		cd /etc/apache2/sites-enabled
		File.islink '080-adminer.conf' || {
			File.into ../sites-available adminer/adminer.conf
			ln -nfs ../sites-available/adminer.conf '080-adminer.conf'
			cmd systemctl restart apache2
		}
	fi;

	Msg.info "Installation of adminer-$v completed!"
}	# end install_adminer


Menu.adminer() {
	install_adminer
}	# end Menu.adminer
