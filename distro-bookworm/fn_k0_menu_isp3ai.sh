# ------------------------------------------------------------------------------
# install ISPConfig 3 for debian 11 bullseye in an automatic fashion
# https://www.howtoforge.com/ispconfig-autoinstall-debian-ubuntu
# ------------------------------------------------------------------------------

Install.isp3() {
	# install ispconfig 3 via automatic installer
	Arg.expect "$1" || return

	local w="${1:-nginx}"
	[ "$w" = 'nginx' ] || w="apache2"

	# install update-inetd
	Pkg.requires update-inetd

	# allow file modification to /etc/resolv.conf
	cmd chattr -i /etc/resolv.conf
	# also append dns-nameservers to network/interfaces
	w=/etc/network/interfaces
	cmd grep -q 'dns-' $w || echo "  dns-nameservers 1.1.1.1 9.9.9.10" >> $w

	# install ispconfig 3
	cmd wget -O - https://get.ispconfig.org | cmd sh -s -- \
		--debug \
		--no-dns \
		--use-unbound \
		--no-mailman \
		--no-quota \
		--use-nginx \
		--use-php=5.6,7.4,8.3 \
		--use-ftp-ports=40110-40210 \
		--no-pma \
		--no-roundcube \
		--i-know-what-i-am-doing
	w=$?	# saving the exit status

	# save passwords for ISPConfig admin & MySQL root
	if [ $w -eq 0 ]; then
		w=/tmp/ispconfig-ai/var/log/setup-*.log
		cmd grep 'admin pass' $w \
			| cmd awk '{print "admin\t" $NF}' \
			> ~/ispconfig.admin
		# save MySQL root password
		cmd grep 'root pass' $w \
			| cmd awk '{print "[client]\nuser=root\npassword=" $NF}' \
			> ~/.my.cnf
		chmod 600 ~/.my.cnf
	fi
}	# end Install.isp3


Menu.isp3ai() {
	# $1: optional webserver type: apache2 or nginx (default)
	HTTP_SERVER="${1:-nginx}"

	# abort if "Menu.deps" was not executed
	Install.isp3 'nginx'

	# allowing on firewall: web, ftp, ispconfig, smtps & mail
	Fw.allow 'http ftp ispconfig smtps mail'

	Menu.adminer
#	install_sslcert_selfsigned
	Config.set "HTTP_SERVER" "$HTTP_SERVER"

	Msg.info "ISPConfig 3 installation completed!"
}	# end Menu.isp3ai
