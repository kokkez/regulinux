# ------------------------------------------------------------------------------
# install adminer, as an alternative to phpmyadmin
# ------------------------------------------------------------------------------

install_adminer() {
	# set: root directory & version
	local u d=/var/www/myadminer v="4.7.8"

	[ -s "$d/index.php" ] && {
		Msg.warn "adminer-$v is already installed..."
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
	if [ "${HTTP_SERVER}" = "nginx" ]; then
		File.into /etc/nginx/snippets adminer/adminer-nginx.conf
		cmd systemctl restart nginx
	else
		cd /etc/apache2/sites-enabled
		File.islink '080-adminer.conf' || {
			File.into ../sites-available adminer/adminer.conf
			ln -nfs ../sites-available/adminer.conf '080-adminer.conf'
			cmd systemctl restart apache2
		}
	fi;

	Msg.info "Installation of adminer-$v completed!"
}	# end install_adminer
