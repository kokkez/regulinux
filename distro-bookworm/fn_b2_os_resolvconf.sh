# ------------------------------------------------------------------------------
# customize the resolver in /etc/resolv.conf with public nameservers
# https://wiki.opennic.org/api/geoip
# ------------------------------------------------------------------------------

DNS.write() {
	local n r="$1"
	# iterating nameservers
	for n in $DNS_v4; do echo "nameserver $n" >> "$r"; done
}	# end DNS.write


DNS.classic() {
	local n r="$1"
	File.backup "$r"

	# set known public dns
	n="search .\noptions timeout:2 rotate\n"

	# install needed packages, if missing
	Pkg.requires e2fsprogs

	# write to /etc/resolv.conf
	[ -s "$r" ] && cmd chattr -i "$r"	# allow file modification
	echo -e "# public dns\n$n" > "$r"
	DNS.write "$r"
	cmd chattr +i "$r"					# deny file modification

	Msg.info "Configuration of public dns completed! Now $r has:"
	sed 's|^|> |' < "$r"
}	# end DNS.classic


DNS.systemd() {
	# configuring DNS with systemd-resolved
	local if="$(Menu.inet if)"
	cmd resolvectl dns $if $(cmd awk '{print $1, $2}' <<< "$DNS_v4")
	cmd resolvectl dns $if $(cmd awk '{print $1, $2}' <<< "$DNS_v6")
}	# end DNS.systemd


DNS.resolvconf() {
	# configuring DNS with resolvconf
	local o r="$1"

	# empty the optional original file
	o=/run/resolvconf/interface/original.resolvconf
	[ -e "$o" ] && > "$o"

	# write nameservers in resolvconf tail
	o=/etc/resolvconf/resolv.conf.d/tail
	[ -e "$o" ] && DNS.write "$o"

	cmd resolvconf -u
	Msg.info "Configuration of public dns completed! Now $r has:"
	sed 's|^|> |' < "$r"
}	# end DNS.resolvconf


OS.resolvconf() {
	# conditional setup of DNS resolvers
	local l r='/etc/resolv.conf'

	# if resolv.conf is a valid symlink, get the real path
	[ File.islink "$r" ] && l=$(cmd readlink -e "$r")

	if [ "$l" = "/run/resolvconf/resolv.conf" ]; then
		Msg.info "Configuring DNS with resolvconf"
		DNS.resolvconf "$r"

	elif pgrep -f "systemd-resolved" > /dev/null; then
		Msg.info "Configuring DNS with systemd-resolved"
		DNS.systemd "$r"

	else
		Msg.info "Configuring DNS in the classic way"
		DNS.classic "$r"
	fi
}	# end OS.resolvconf
