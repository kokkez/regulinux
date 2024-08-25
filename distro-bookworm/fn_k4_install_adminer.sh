# ------------------------------------------------------------------------------
# install adminer, as an alternative to phpmyadmin
# ------------------------------------------------------------------------------

Install.adminer() {
	# enable ports on ufw firewall
	# $1 - version of adminer
	# $2 - webserver: apache2, nginx
	Arg.expect "$1" || return
	Arg.expect "$2" || return

	# set: root directory & version
	local a n u d=/var/www/myadminer v="$1"

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
	if [ "$2" = "nginx" ]; then
		File.into /etc/nginx/snippets adminer/adminer-nginx.conf
		systemctl restart nginx

	elif [ "$2" = "apache2" ]; then
		cd /etc/apache2/sites-enabled
		File.islink '080-adminer.conf' || {
			File.into ../sites-available adminer/adminer.conf
			ln -nfs ../sites-available/adminer.conf '080-adminer.conf'
			systemctl restart apache2
		}
	fi;

	cd ~
	Msg.info "Installation of adminer-$v completed!"
}	# end Install.adminer


Menu.adminer() {
	# install adminer for webserver: apache2, nginx
	local w v="4.8.1"

	# check for webserver
	if systemctl is-active -q apache2; then
		Install.adminer "$v" apache2

	elif systemctl is-active -q nginx; then
		Install.adminer "$v" nginx

	else
		Msg.warn "No active webservers found for adminer-$v..."
	fi
}	# end Menu.adminer

