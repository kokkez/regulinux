# ------------------------------------------------------------------------------
# one of the first bench test found on the net, customized by kokkez
# ------------------------------------------------------------------------------

Bench.cmd() {
	# run the benchmark & output the time
	# $1 textual label to echo as is
	Cmd.usable "$2" && {
		TIMEFORMAT='%3R seconds'
		echo -n "> $1 (500MiB): "
		time dd if=/dev/zero bs=1M count=500 2> /dev/null | "${@:2}" > /dev/null
	}
}	# end Bench.cmd


Bench.newssl() {
	# Instead of looking for versions greater than or equal to 1.1.1, this looks
	# for versions less than 1.1.1: versions starting with "0.", "1.0", or "1.1.0"
	# https://unix.stackexchange.com/questions/555731/how-to-check-if-the-openssl-version-is-ge-1-1-1-in-a-shell-script
	cmd openssl version | cmd awk '$2 ~ /(^0\.)|(^1\.(0\.|1\.0))/ { exit 1 }'
}	# end Bench.newssl


Menu.bench() {
	# basic benchmark to get OS info
	# no arguments expected
	local ts vir cpu cor mhz ram swa ker hdd ip4 ip6

	# current date
	ts=$(cmd date -u '+%F %T UTC')
	# virtualization
	vir=$(cmd hostnamectl | cmd awk '/Vir/{print $2}')
	[ -z "$vir" ] && vir="unknown"
	# Processor model
	cpu=$(cmd awk '/^model n/{$1=$2=$3="";print substr($0,4);exit}' /proc/cpuinfo)
	# how many CPU cores
	cor=$(cmd grep -c ^pro /proc/cpuinfo)
	# CPU clock
	mhz=$(cmd awk '/^cpu M/{1*$4 > x && x = 1*$4} END {print x "MHz"}' /proc/cpuinfo)
	# how many ram in Mb
	ram=$(cmd awk '/^MemT/{print int($2 / 1024) "MB"}' /proc/meminfo)
	# how many swap in Mb
	swa=$(cmd awk '/^SwapT/{print int($2 / 1024) "MB"}' /proc/meminfo)
	# linux kernel
	ker=$(cmd uname -srm)
	# disks
#	hdd=$(cmd df -kl | cmd awk '/^\/dev/{printf("  %dGB %s\n",$2 / 1024000,$NF)}')
	hdd=$(cmd df -kl | cmd awk '/^\/dev/{printf("  %dGiB %s\n",$2 / 1048576,$NF)}')
	[ -z "$hdd" ] && hdd="  none founds"
	# IPv4
	ip4=$(printf '  %s\n' $(hostname -I) | cmd grep -v :)
	[ -z "$ip4" ] && ip4="  none founds"
	# IPv6
	ip6=$(printf '  %s\n' $(hostname -I) | cmd grep :)
	[ -z "$ip6" ] && ip6="  none founds"

	cmd cat <<- EOF
		----------------------- OS Benchmark -- $ts --
		> Virtualization: $vir
		> RAM:            $ram
		> Swap:           $swa
		> Processor:      $cpu
		> CPU cores:      $cor
		> Frequency:      $mhz
		> Kernel:         $ker
		------------------------------------------------------------------
		> Disks:
		  $hdd
		> IPv4:
		  $ip4
		> IPv6:
		  $ip6
		------------------------------------------------------------------
		EOF

	# CPU tests
	Bench.cmd 'CPU: SHA256-hashing   ' sha256sum
	Bench.cmd 'CPU: bzip2-compressing' bzip2
	Bench.newssl && ts='-pbkdf2' || ts=''
	Bench.cmd 'CPU: AES-encrypting   ' openssl enc -e -aes-256-cbc $ts -pass pass:12345678
}	# end Menu.bench
