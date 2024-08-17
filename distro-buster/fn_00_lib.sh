# ------------------------------------------------------------------------------
# custom functions specific to debian 10 buster
# ------------------------------------------------------------------------------

Menu.upgrade() {
	Msg.info "Upgrading system packages for ${ENV_os}..."
	Pkg.update	# update packages lists

	# do the apt upgrade
	export DEBIAN_FRONTEND=noninteractive
	cmd apt -qy full-upgrade
}	# end Menu.upgrade


Net.time() {
	local t=$1
    cmd printf "%d.%02d" $((t / 1000)) $(((t % 1000) / 10))
}	# end Net.time


Net.speed() {
	local url="http://speedtest.tele2.net/100MB.zip"
	local tmp=$(cmd mktemp)

	# download speed in milliseconds
	Msg.info "Measuring download speed..."
	local begin=$(cmd date +%s%3N)
	cmd curl -o "$tmp" -s "$url"
	local until=$(cmd date +%s%3N)

	local fsize=$(cmd stat -c %s "$tmp")	# file size from filesystem in bytes
	local mb=$(( fsize / 1048576 ))			# convert to MB: 1 MB = 1024 * 1024 bytes

	# elapsed time to seconds with milliseconds approximation
	local elaps=$((until - begin))			# time in milliseconds
	local speed=$(( (fsize * 1000) / (elaps * 1024) ))	# download speed in KB/s
	local ft=$(Net.time $elaps)
	Msg.info "Download speed: $speed KB/s ($mb MB in $ft s)"

	# Measure upload speed (fake upload to nowhere)
	Msg.info "Measuring upload speed..."
	begin=$(cmd date +%s%3N)
	cmd curl -o /dev/null -s -F "file=@$tmp" "https://httpbin.org/post"
	until=$(cmd date +%s%3N)

	elaps=$((until - begin))			# time in milliseconds
	speed=$(( (fsize * 1000) / (elaps * 1024) ))	# upload speed in KB/s
	ft=$(Net.time $elaps)
	Msg.info "Upload speed: $speed KB/s ($mb MB in $ft s)"

	cmd rm -f "$tmp"	# Clean up
}	# end Net.speed


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


Repo.php() {
	# add external repository for updated php
	local p='/etc/apt/sources.list.d/php.list'
	[ -s "$p" ] && return

	# add external repository for updated php
	Pkg.requires apt-transport-https lsb-release ca-certificates
	File.download https://packages.sury.org/php/apt.gpg /etc/apt/trusted.gpg.d/php.gpg
	cat > "$p" <<-EOF
		# https://www.patreon.com/oerdnj
		deb http://packages.sury.org/php $ENV_codename main
		#deb-src http://packages.sury.org/php $ENV_codename main
		EOF
	# forcing apt update
	Pkg.update 'coerce'
}	# end Repo.php


# legacy version of the iptables commands, needed by firewall
Fw.ip4() { cmd iptables-legacy "$@"; }
Fw.ip6() { cmd ip6tables-legacy "$@"; }
Fw.ip4save() { cmd iptables-legacy-save "$@"; }
Fw.ip6save() { cmd ip6tables-legacy-save "$@"; }
