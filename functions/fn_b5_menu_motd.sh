# ------------------------------------------------------------------------------
# the "Mot Of The Day" screen printed on terminal when an user connect
# ------------------------------------------------------------------------------

Install.motd.old() {
	local p='/etc/update-motd.d'

	# abort if MOTD is already installed
	[ -s "$p/*-footer" ] && return

	# install needed packages, if missing
	Pkg.requires figlet lsb-release

	# copying files & make them executables
	mkdir -p "$p"
	rm -rf $p/*
	File.into "$p" motd/*
	chmod +x $p/*

	# remove /etc/motd on pure debian
	cmd rm -f /etc/motd

	# relink /etc/motd on debian jessie
	[ "$ENV_release" = "debian-8" ] && ln -nfs /run/motd /etc/motd

	Msg.info "Customization of MOTD completed!"
}	# end Install.motd.old


Install.motd() {
	# from 2024 onward we use a single file into /etc/profiles.d/
	# so only when really connected via terminal we have the nice MOTD screen
	local p='/etc/profile.d'

	# abort if MOTD is already installed
	[ -s "$p/motd-console.sh" ] && return

	# install needed packages, if missing
	Pkg.requires figlet lsb-release

	# simply copying file
	File.into "$p" motd/motd-console.sh

	# always empty the motd folder
	rm -rf /etc/update-motd.d/*
	cmd rm -f /etc/motd		# remove this on pure debian

	Msg.info "Installation of MOTD completed!"
}	# end Install.motd


Motd.show() {
	# install needed packages, if missing
	Pkg.requires figlet lsb-release

	figlet -w 96 -f small $(hostname -f)
	printf "Driven by the sheer brilliance of %s Kernel %s\n" "$ENV_os $ENV_arch" "$(uname -r)"

	proc=$(echo /proc/[0-9]* | wc -w)
	chss=$(systemd-detect-virt)
	chss="$(hostnamectl chassis) ( ${chss:-dedi} )"
	load=$(awk '{print $1, $2, $3}' /proc/loadavg)
	tram=$(awk '/^MemT/{print int($2 / 1024) "MB"}' /proc/meminfo)
	uram=$(awk '/^MemT/{ t=$2 } /^MemF/{ f=$2 } /^Cach/{ f+=$2 } /^Buff/{ f+=$2 } END { printf("%3.1f%%", (t-f)/t*100)}' /proc/meminfo)
	ip4n=$(wget --timeout=4 --tries=1 -q4O- https://ip.rootnet.in)
	ip4c=$(hostname -i)
	tswa=$(awk '/^SwapT/{print int($2 / 1024) "MB"}' /proc/meminfo)
	uswa="-"
	[ "$tswa" != "0MB" ] && {
		uswa=$(awk '/^SwapT/{ t=$2 } /^SwapF/{ f=$2 } END { printf("%3.1f%%", (t-f)/t*100)}' /proc/meminfo)
	}
	time=$(uptime -p);
	time=${time#up }
	disk=$(df -P | awk '$NF=="/" {printf("%dGiB", $2/1048576)}')
	uhdd=$(df -P | awk '$NF=="/" {print $(NF-1)}')
	date=$(date +'%F %T %z')

	echo
	printf "Chassis: %-16s\tSystem load:\t%s\n"                   "$chss" "$load / $proc proc"
	printf "RAM:     %6s of %-6s\tIPv4: net [cfg]\t%s [ %s ]\n"   "$uram" "$tram" "$ip4n" "$ip4c"
	printf "Swap:    %6s of %-6s\tSystem uptime:\t%s\n"           "$uswa" "$tswa" "$time"
	printf "Storage: %6s of %-6s\tCurrent date:\t%s\n"            "$uhdd" "$disk" "$date"
	echo
}	# end Motd.show


Menu.motd() {
	# metadata for OS.menu entries
	__section='Standalone utilities'
	__summary="the MOTD displayed after successful interactive login"

	Motd.show				# print motd
	[[ $1 ]] && exit 0		# kill here if called from /etc/profile.d
}	# end Menu.motd
