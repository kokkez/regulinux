# ------------------------------------------------------------------------------
# append keywords (ports) to the firewall script to allow connections
# ------------------------------------------------------------------------------

firewall_allow() {
	# append keywords to var "ACCEPTS" in ~/firewall.sh

	local u w f=~/firewall.sh			# path to the firewall script
	[ -r "${f}" ] || return				# silently returns on missing script
	[ -z "${1}" ] && return				# silently returns if no arguments
	source <(grep '^ACCEPTS=' ${f})		# current allowed keywords (ports)

	# unique-ize arguments
	u=($( tr [:space:] '\n' <<< "${ACCEPTS} ${@}" | awk '!_[$0]++' ))

	# test existance of firewall rules
	ACCEPTS=""
	for w in ${u[@]}; do
		grep -Pq "^manage_${w}\\(" ${f} && ACCEPTS="${ACCEPTS} ${w}"
	done

	# save the new value back in ~/firewall.sh
	Msg.info "Allowing on firewall: ${ACCEPTS## }"
	sed -ri ${f} -e "s|^(ACCEPTS=).*|\1\"${ACCEPTS## }\"|"

	${f} start							# load configured rules on firewall
};	# end firewall_allow
