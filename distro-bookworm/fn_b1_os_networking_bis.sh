# ------------------------------------------------------------------------------
# make the ip address static if found to be dynamic, on classic ifupdown
# standardize the networking of sebian 12, using 
# ------------------------------------------------------------------------------

Net.info() {
	# return values for the network interface connected to the Internet
	# $1 - optional, desired result: if, mac, cidr, ip, gw, cidr6, ip6, gw6
	local if=$(cmd ip r get 1 | cmd grep -oP 'dev \K\S+')
	local mac=$(cmd ip -br l show "$if" | cmd awk '{print $3}')
	local c4=$(cmd ip -br -4 a show "$if" | cmd awk '{print $3}')
	local g4=$(cmd ip r get 1 | cmd grep -oP 'via \K\S+')
	local a4=${c4%%/*}

	# check if IPv6 is enabled
	local g6 a6 v=$(cmd ip a s scope global)
	local c6=$(cmd grep -oP 'inet6 \K\S+' <<< "$v")
	if [ -n "$c6" ]; then
		g6=$(cmd ip r get :: | cmd grep -oP 'via \K\S+')
		a6=${c6%%/*}
	fi

	case "$1" in
		m*)   echo ${mac,,} ;;
		c*6*) echo $c6 ;;
		c*)   echo $c4 ;;
		g*6*) echo $g6 ;;
		g*)   echo $g4 ;;
		i*6*) echo $a6 ;;
		if*)  echo $if ;;
		i*)   echo $a4 ;;
		*)    cat <<- EOF
			> Network Interface : $if
			> MAC Address       : ${mac,,}
			----------------------------------------------------------
			> IPv4 CIDR         : $c4
			> IPv4 Address      : $a4
			> IPv4 Gateway      : $g4
			----------------------------------------------------------
			> IPv6 CIDR         : ${c6:-N/A}
			> IPv6 Address      : ${a6:-N/A}
			> IPv6 Gateway      : ${g6:-N/A}
			----------------------------------------------------------
			EOF
	esac
}	# end Net.info
