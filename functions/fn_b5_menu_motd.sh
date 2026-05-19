# ------------------------------------------------------------------------------
# the "Mot Of The Day" screen printed on terminal when an user connect
# ------------------------------------------------------------------------------

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

	figlet -w 96 -f small $(hostname -f) | awk '{print "  " $0}'
	printf "  Driven by %s with kernel %s\n" "$ENV_os $ENV_arch" "$(uname -r)"
	echo -e "- ---------------------------------------------------------------------------- -"

	proc=$(awk -F': ' '/model n/{print $2; exit}' /proc/cpuinfo)
	core=$(nproc)
	date=$(date +'%F %T %z')
	time=$(uptime -p); time=${time#up }

	load=$(awk '{printf "%s  %s  %s", $1, $2, $3}' /proc/loadavg)
	task=$(ps -e --no-headers | wc -l)
	form=$(systemd-detect-virt)
	form="$(hostnamectl | awk '/Cha/ {print $2}') ( ${form:-dedi} )"

	bar() { perl -e "printf '[%s%s]', '#' x int($1/4), '-' x (25 - int($1/4))"; }
	memt=$(free -h | awk '/^Mem:/ {print $2}')
	memp=$(free | awk '/^Mem:/ {printf "%.0f", $3/$2*100}')
	memb=$(bar $memp)
	swpt=$(free -h | awk '/^Swap:/ {print $2}')
	if [ "$swpt" = "0B" ] || [ -z "$swpt" ]; then
		swpt="-"
		swpp=0
	else
		swpp=$(free | awk '/^Swap:/ {printf "%.0f", $3/$2*100}')
	fi
	swpb=$(bar $swpp)

	ipc4=$(Menu.inet c4)
	ip4h=$(hostname -i)
	ifc4=$(Menu.inet if4)
	mac4=$(Menu.inet ma4)
	ipc6=$(Menu.inet c6);  ipc6=${ipc6:-"-"}
	ifc6=$(Menu.inet if6); ifc6=${ifc6:-"-"}
	mac6=$(Menu.inet ma6); mac6=${mac6:-"-"}

	printf  "  cpu      %s \n"                             "$proc  //  $core core[s]"
	printf  "  date     %-33s uptime  %s \n"               "$date" "$time"
	printf  "  load     %-35s form  %s \n"                 "$load  //  $task task[s]" "$form"
	printf  "  ipv4     %-33s %6s  %s \n"                  "$ipc4  [ $ip4h ]" "$ifc4" "$mac4"
	printf  "  ipv6     %-33s %6s  %s \n"                  "$ipc6" "$ifc6" "$mac6"
	echo -e "- TAG ---- SIZE ------------------------------ USED --------- FREE ----------- -"
	printf  "  ram      %-6s %-27s %4s%% \n"               "$memt" "$memb" "$memp"
	printf  "  swap     %-6s %-27s %4s%% \n"               "$swpt" "$swpb" "$swpp"

	for moun in / /srv /var; do
		[ -d "$moun" ] || continue
		disk=$(df "$moun" | awk 'NR==2 {print $1}')
		[ "$prev" = "$disk" ] && continue
		prev=$disk
		read size used free p <<< $(df -h "$moun" | awk 'NR==2 {print $2, $3, $4, $5}')
		perc=${p%\%}
		barp=$(bar $perc)
		frep=$(( 100 - perc ))
		printf "  %-8.8s %-6s %s %5s %3s%% %9s %3s%%\n"    "$moun" "$size" "$barp" "$used" "$perc" "$free" "$frep"
	done
	echo
}	# end Motd.show


Menu.motd() {
	# metadata for OS.menu entries
	__section='Standalone utilities'
	__summary="the MOTD displayed after successful interactive login"

	Motd.show				# print motd
	[[ $1 ]] && exit 0		# kill here if called from /etc/profile.d
}	# end Menu.motd
