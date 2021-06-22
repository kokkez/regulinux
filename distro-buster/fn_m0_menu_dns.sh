# ------------------------------------------------------------------------------
# install bind9 DNS server 9.11.5 for debian 10 buster
# https://reposcope.com/package/bind9
# ------------------------------------------------------------------------------

menu_dns() {
	if is_installed "bind9"; then
		msg_alert "DNS server bind9 is already installed..."
		return
	fi;

	# abort if the system is not set up properly
	done_deps || return

	# install the DNS server
	msg_info "Installing DNS server bind9..."

	pkg_install bind9 dnsutils
	touch /var/log/bind9-query.log
	chown bind:0 /var/log/bind9-query.log
	copy_to ~ getSlaveZones.sh

	# activating ports on firewall
	firewall_allow "dns"

	msg_info "Installation of DNS server bind9 completed!"
}	# end menu_dns
