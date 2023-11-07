# ------------------------------------------------------------------------------
# install ispconfig3 for debian 11 bullseye in an automatic fashion
# https://www.howtoforge.com/ispconfig-autoinstall-debian-ubuntu
# ------------------------------------------------------------------------------

Menu.isp3ai() {
	# $1: optional webserver type: nginx or apache2
	HTTP_SERVER="${1:-$HTTP_SERVER}"

	# abort if "Menu.deps" was not executed
	Deps.performed || return

	# install update-inetd
	Pkg.requires update-inetd

	# allow file modification to /etc/resolv.conf
	cmd chattr -i /etc/resolv.conf

	# install webserver (nginx or apache2)
	cmd wget -O - https://get.ispconfig.org | cmd sh -s -- \
		--debug \
		--no-dns \
		--use-unbound \
		--no-mailman \
		--no-quota \
		--use-amavis \
		--use-nginx \
		--use-php=5.6,7.4,8.3 \
		--use-ftp-ports=40110-40210 \
		--no-pma \
		--unattended-upgrades \
		--i-know-what-i-am-doing

	install_adminer
#	install_sslcert_selfsigned
}	# end Menu.isp3ai
