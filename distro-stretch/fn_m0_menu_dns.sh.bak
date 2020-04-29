# ------------------------------------------------------------------------------
# install the AntiSpam SMTP Proxy version 1 (min 384ram 1core)
# ------------------------------------------------------------------------------

menu_dns() {
	if is_installed "bind9"; then
		msg_alert "DNS server bind9 is already installed..."
		return
	fi;

	# verify that the system was set up
	done_deps || return

	# install the DNS server
	msg_info "Installing DNS server bind9..."

	pkg_install bind9 dnsutils
	touch /var/log/bind9-query.log
	chown bind:0 /var/log/bind9-query.log

	msg_info "Installation of DNS server bind9 completed!"
}	# end menu_dns
