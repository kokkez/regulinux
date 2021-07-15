# ------------------------------------------------------------------------------
# open port[s] via iptables appending keyword[s] to the firewall script
# ------------------------------------------------------------------------------

Firewall.allow() {
	# append keywords to var "ACCEPTS" in ~/firewall.sh
	# $1 - keyword mapped to a Rule.<keyword> function in ~/firewall.sh
	Arg.expect "$1" || return 0

	local u w f=~/firewall.sh			# path to the firewall script
	[ -s "$f" ] || return				# silently returns on missing script
	source <( grep '^ACCEPTS=' $f )		# current allowed keywords (ports)

	# unique-ize arguments
	u=($( tr [:space:] '\n' <<< "$ACCEPTS $@" | awk '!_[$0]++' ))

	# test existance of firewall rules
	ACCEPTS=""
	for w in ${u[@]}; do
		grep -Pq "^Rule.$w\\(" $f && ACCEPTS+=" $w"
	done

	# save the new value back in ~/firewall.sh
	Msg.info "Allowing on firewall:${ACCEPTS}"
	sed -ri $f -e "s|^(ACCEPTS=).*|\1\"${ACCEPTS## }\"|"

	$f start							# load configured rules on firewall
};	# end Firewall.allow
