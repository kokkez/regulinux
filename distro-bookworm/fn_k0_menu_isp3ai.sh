# ------------------------------------------------------------------------------
# install ISPConfig 3 for debian 12 bookworm in an automatic fashion
# https://www.howtoforge.com/ispconfig-autoinstall-debian-ubuntu
# ------------------------------------------------------------------------------

IC3.finishing() {
	# remove some memory intensive apps, obsoleted by assp
	systemctl stop rspamd
	systemctl disable rspamd
	apt-get -qy purge --auto-remove clamav clamav-daemon postgrey rspamd

	# remove apt source for rspamd
	rm -rf /etc/apt/sources.list.d/rspamd.list

	# install postfix sasl mechanism & some utilities
	apt-get -y install libsasl2-modules pfqueue swaks

	# commenting lines in postfix main.cf file
	local p=/etc/postfix/main.cf
	File.backup "$p"
	sed -i "$p" \
		-e '/greylisting/s/^/#/' \
		-e '/milter/s/^/#/'

	# stopping awfful from looking for apache logs
	local f=/etc/cron.daily/awffull
	[ -f "$f" ] && { chmod -x "$f"; mv "$f" "$f.disabled"; }
};	# end IC3.finishing


IC3.secret() {
	local w
	# save passwords for ISPConfig admin & MySQL root
	w=~/ispconfig-install-log/setup-*.log
	grep 'admin pass' $w \
		| awk '{print "admin\t" $NF}' \
		> ~/ispconfig.admin
	# save MySQL root password
	grep 'root pass' $w \
		| awk '{print "[client]\nuser=root\npassword=" $NF}' \
		> ~/.my.cnf
	chmod 600 ~/.my.cnf
};	# end IC3.secret


IC3.install() {
	# install ispconfig 3 via automatic installer
	Arg.expect "$1" || return

	local w="${1:-nginx}"
	[ "$w" = 'nginx' ] || w="apache2"

	# install update-inetd
	Pkg.requires update-inetd

	# allow modification of /etc/resolv.conf
	chattr -i /etc/resolv.conf

	# install ispconfig 3
	wget -O - https://get.ispconfig.org | sh -s -- \
		--debug \
		--no-firewall \
		--no-dns --no-local-dns \
		--no-mailman \
		--no-quota \
		--no-ntp \
		--no-pma \
		--no-roundcube \
		--use-nginx \
		--use-php=5.6,7.4,8.3 \
		--use-ftp-ports=40110-40210 \
		--i-know-what-i-am-doing
	w=$?	# saving the exit status

	# on errors dont continue
	(( w )) && return 1

	IC3.secret		# save IC3 admin & MySQL root passwords
	IC3.finishing	# install utilities, remove unused apps
};	# end IC3.install


Menu.isp3ai() {
	__exclude='[ -f /usr/local/ispconfig/server/server.php ]'
	__section='Target system'
	__summary="historical Control Panel, with support at $(Dye.fg.white howtoforge.com)"

	# abort if "Menu.deps" was not executed
	Deps.performed || return

	# install for webserver nginx
	HTTP_SERVER='nginx'
	IC3.install "$HTTP_SERVER"
	Config.set "HTTP_SERVER" "$HTTP_SERVER"

	# allowing on firewall: web, ftp, ispconfig, smtps & mail
	Fw.allow 'http ftp ispconfig smtps mail'

	Menu.adminer
	Cmd.usable Menu.issue && Menu.issue "$HOST_FQDN"

	Msg.info "ISPConfig 3 installation completed!"
};	# end Menu.isp3ai
