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

	# allow modification to /etc/resolv.conf
	cmd chattr -i /etc/resolv.conf

	# install ispconfig 3
	cmd wget -O - https://get.ispconfig.org | cmd sh -s -- \
		--debug \
		--no-firewall \
		--no-dns \
		--no-local-dns \
		--no-mailman \
		--no-quota \
		--no-ntp \
		--no-pma \
		--no-roundcube \
		--use-nginx \
		--use-php=5.6,7.4,8.3 \
		--use-ftp-ports=40110-40210 \
		--i-know-what-i-am-doing

	# on errors dont continue
	[ $? -eq 0 ] || return 1

	local l=/tmp/ispconfig-ai/var/log/setup-*.log
	# save ISPConfig admin password
	cmd grep 'admin pass' $l \
		| cmd awk {'print "admin\t" $NF'} \
		> ~/ispconfig.admin
	# save MySQL root password
	cmd grep 'root pass' $l \
		| cmd awk {'print "[client]\nuser=root\npassword=" $NF'} \
		> ~/.my.cnf
	chmod 600 ~/.my.cnf
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
