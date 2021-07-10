# ------------------------------------------------------------------------------
# append keywords (ports) to the firewall script to allow connections
# ------------------------------------------------------------------------------

firewall_allow() {
	# append keywords to var "ACCEPTS" in ~/firewall.sh

	local U W F=~/firewall.sh			# path to the firewall script
	[ -s "${F}" ] || return				# silently returns on missing script
	[ -z "${1}" ] && return				# silently returns if no arguments
	source <(grep '^ACCEPTS=' ${F})		# current allowed keywords (ports)

	# unique-ize arguments
	U=($( tr [:space:] '\n' <<< "${ACCEPTS} ${@}" | awk '!_[$0]++' ))

	# test existance of firewall rules
	ACCEPTS=""
	for W in ${U[@]}; do
		grep -Pq "^manage_${W}\\(" ${F} && ACCEPTS="${ACCEPTS} ${W}"
	done

	# save the new value back in ~/firewall.sh
	Msg.info "Allowing on firewall: ${ACCEPTS## }"
	sed -ri ${F} -e "s|^(ACCEPTS=).*|\1\"${ACCEPTS## }\"|"

	${F} start							# load configured rules on firewall
};	# end firewall_allow
