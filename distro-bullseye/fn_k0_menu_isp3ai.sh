# ------------------------------------------------------------------------------
# install ispconfig3 for debian 11 bullseye in an automatic fashion
# https://www.howtoforge.com/ispconfig-autoinstall-debian-ubuntu
# ------------------------------------------------------------------------------

Menu.isp3ai() {
	# $1: optional webserver type: apache2 or nginx (default)
	HTTP_SERVER="${1:-nginx}"

	# abort if "Menu.deps" was not executed
	Deps.performed || return

	# install update-inetd
	Pkg.requires update-inetd

	# allow file modification to /etc/resolv.conf
	cmd chattr -i /etc/resolv.conf

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

#		--use-amavis \
#		--unattended-upgrades \

	# allowing on firewall: web, ftp, ispconfig, smtps & mail
	Fw.allow 'http ftp ispconfig smtps mail'

	Menu.adminer
#	install_sslcert_selfsigned
	Config.set "HTTP_SERVER" "$HTTP_SERVER"
}	# end Menu.isp3ai
