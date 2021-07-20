# ------------------------------------------------------------------------------
# open port[s] via iptables appending keyword[s] to the firewall script
# ------------------------------------------------------------------------------

Firewall.allow() {
	# append keywords to var $ACCEPTS in ~/firewall.sh
	# $1 - keyword mapped to a Rule.<keyword> function in ~/firewall.sh
	Arg.expect "$1" || return

	local a w f=~/firewall.sh			# path to the firewall script
	[ -s "$f" ] || return				# silently returns on missing script
	source <( grep '^ACCEPTS=' "$f" )	# current allowed keywords (ports)

	# unique-ize valid arguments
	for w in $ACCEPTS $@; do
		! Element.in $w $a && grep -Pq "^Rule.$w\\(" "$f" && a+=" $w"
	done

	# save the new value back in ~/firewall.sh
	Msg.info "Allowing on firewall:$a"
	sed -ri "$f" -e "s|^(ACCEPTS=).*|\1'${a:1}'|"

	"$f" start							# load configured rules on firewall
};	# end Firewall.allow
