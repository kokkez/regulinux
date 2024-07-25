#!/bin/bash
#
# this is a Message of the Day (MOTD) replacement. It will display its
# information only after the login process has completed, eliminating
# access issues for automated systems that do not benefit from these
# calculations, such as backup systems, as well as SSH accesses without
# a terminal, such as WinSCP
#
# Copyleft (c) 2024 Luigi Cocconcelli

# stop here if not connected to a terminal or if "~/.hushlogin" exists
[ ! -t 1 ] || [ -f ~/.hushlogin ] && return

figlet -w 96 -f small $(hostname -f)
printf "Welcome to %s Kernel %s\n" \
	"$(hostnamectl | awk -F': ' '/Op/{print $2}')" \
	"$(uname -r)"

proc=$(ps aux | wc -l)
chss=$(hostnamectl | awk '/Vir/{print $2}')
chss=${chss:-dedi}
chss="$(hostnamectl | awk '/Cha/{print $2}') ( $chss )"
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
time=$(uptime | sed -e 's/^[^,]*up *//' -e 's/, *[[:digit:]]* user.*//')
disk=$(df -kl / | awk '/\//{printf("%dGiB",$2/1048576)}')
uhdd=$(df -h / | awk '/\// {print $(NF-1)}')
date=$(date +'%F %T %z')

echo
printf "Chassis: %-16s\tSystem load:\t%s\n"                   "$chss" "$load / $proc proc"
printf "RAM:     %6s of %-6s\tIPv4: net [cfg]\t%s [ %s ]\n"   "$uram" "$tram" "$ip4n" "$ip4c"
printf "Swap:    %6s of %-6s\tSystem uptime:\t%s\n"           "$uswa" "$tswa" "$time"
printf "Storage: %6s of %-6s\tCurrent date:\t%s\n"            "$uhdd" "$disk" "$date"
echo
