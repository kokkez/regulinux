# ------------------------------------------------------------------------------
# install bind9 DNS server 9.10.3 for debian 9 stretch
# https://reposcope.com/package/bind9
# ------------------------------------------------------------------------------

Menu.dns() {
	if Pkg.installed "bind9"; then
		Msg.warn "DNS server bind9 is already installed..."
		return
	fi;

	# abort if "Menu.deps" was not executed
	Deps.performed || return

	# install the DNS server
	Msg.info "Installing DNS server bind9 for ${ENV_os}..."

	Pkg.install bind9 dnsutils
	touch /var/log/bind9-query.log
	chown bind:0 /var/log/bind9-query.log
	File.into ~ getSlaveZones.sh

	# activating ports on firewall
	Fw.allow 'dns'

	Msg.info "Installation of DNS server bind9 completed!"
}	# end Menu.dns
