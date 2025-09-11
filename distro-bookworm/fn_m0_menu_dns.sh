# ------------------------------------------------------------------------------
# install bind9 DNS server 9.11.4 for ubuntu 18.04 bionic
# https://reposcope.com/package/bind9
# ------------------------------------------------------------------------------

Menu.dns() {
	# metadata for OS.menu entries
	__section='Target system'
	__summary="bind9 DNS slave server with some related utilities"

	# abort if bind9 is already installed
	if Pkg.installed "bind9"; then
		Msg.warn "DNS server bind9 is already installed..."
		return
	fi;

	# abort if "Menu.deps" was not executed
	Deps.performed || return

	# install the DNS server
	Msg.info "Installing DNS server bind9 for ${ENV_os}..."

	Pkg.install bind9 bind9utils bind9-dnsutils dnsutils
	touch /var/log/bind9.log
	chown bind:0 /var/log/bind9.log
	File.into ~ get-my-zones.sh

	# activating ports on firewall
	Fw.allow 'dns'

	Msg.info "Installation of DNS server bind9 completed!"
}	# end Menu.dns
