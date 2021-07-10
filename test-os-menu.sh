#!/bin/bash
# ==============================================================================

#	VARIABLES
#	global variables
#	----------------------------------------------------------------------------


#	FUNCTIONS
#	companion functions
#	----------------------------------------------------------------------------
	Dye.as() {
		# output painted text
		# expects:
		#  $1 num : type (default 0, dark)
		#  $2 num : color (default 37, gray)
		#  $3 text: message to colorize
		echo -e "\e[${1:-0};${2:-37}m${@:3}\e[0m";
	};
	Dye.fg.red()         { Dye.as 0 31 "$@"; };
	Dye.fg.red.lite()    { Dye.as 1 31 "$@"; };
	Dye.fg.green()       { Dye.as 0 32 "$@"; };
	Dye.fg.green.lite()  { Dye.as 1 32 "$@"; };
	Dye.fg.yellow()      { Dye.as 0 33 "$@"; };
	Dye.fg.yellow.lite() { Dye.as 1 33 "$@"; };
	Dye.fg.blue()        { Dye.as 0 34 "$@"; };
	Dye.fg.blue.lite()   { Dye.as 1 34 "$@"; };
	Dye.fg.purple()      { Dye.as 0 35 "$@"; };
	Dye.fg.purple.lite() { Dye.as 1 35 "$@"; };
	Dye.fg.cyan()        { Dye.as 0 36 "$@"; };
	Dye.fg.cyan.lite()   { Dye.as 1 36 "$@"; };
	Dye.fg.gray()        { Dye.as 0 37 "$@"; };
	Dye.fg.gray.lite()   { Dye.as 1 37 "$@"; };
	Dye.fg.orange()      { Dye.as "38;5" 214 "$@"; };


	cmd() {
		# try run a real command, not an aliased version
		# on missing command, or error, it silently returns
		[ -n "$1" ] && [ -n "$( command -v $1 )" ] && command "$@"
	};	# end cmd

	Arg.expect() {
		# helper function for verifying args in functions
		# expects: variable number of arguments ( $1 [, $2 [, $3 ... ]] )
		local i=1
		for (( ; i<=$#; i++ )); do
			[ -z "${!i}" ] && echo "Missing argument" \
				$( Dye.fg.yellow.lite "#$i" ) "to" \
				$( Dye.fg.yellow.lite "${FUNCNAME[1]}()" ) \
				&& return 1
		done
		return 0
	};

	Arr.index() {
		# returns a list of array indexes
		# eg. => 0 1 3 4 6
		# $1 an indexed array
		Arg.expect "$1" && eval echo \${!${1}[@]}
	}

	is_available() {
		# test argument $1 for: not empty & callable
		Arg.expect "$1" && command -v "$1" &> /dev/null
	}	# end is_available

	detect_linux() {
		# detect OS info (LINUX, VERSION, DISTRO)
		# thanks to Mikel (http://unix.stackexchange.com/users/3169/mikel) for idea

		# user must be root (id == 0)
		(( $(cmd id -u) )) && {
			Msg.error "This script must be run by the user: ${cWITELITE}root${cNULL}"
		}
		local x t
		Dye.fg.gray "You are currently logged as:" $( Dye.fg.gray.lite $( cmd id -un ) )

		# test the presence of some required commands
		for x in awk apt-get cat cd cp debconf-set-selections dpkg \
			dpkg-reconfigure find grep head mkdir mv perl rm sed tr;
		do
			is_available "$x" \
				|| Dye.fg.gray "Missing command:" $( Dye.fg.gray.lite "$x" )
		done

		# set some environmental vars
		OS_arch=$( cmd uname -m )
		OS_path=$( cd "${BASH_SOURCE[0]%/*}" && pwd )
		OS_files="$OS_path/files-common"

		# get info on system
		if [ -f /etc/lsb-release ]; then
			. /etc/lsb-release
			LINUX=${DISTRIB_ID,,}			# debian, ubuntu, ...
			VERSION=${DISTRIB_RELEASE,,}	# 7, 14.04, ...
		elif [ -f /etc/os-release ]; then
			. /etc/os-release
			LINUX=${ID,,}					# debian, ubuntu, ...
			VERSION=${VERSION_ID,,}			# 7, 14.04, ...
		elif [ -f /etc/issue.net ]; then
			t=$(head -1 /etc/issue.net)
			LINUX=$(awk '{print $1}' <<< ${t,,})
			VERSION=$(perl -pe '($_)=/(\d+([.]\d+)+)/' <<< ${t,,})
		fi;

		# assigning distribution pretty name
		OS_info="${LINUX}-${VERSION}"

		case "$OS_info" in
		#	"debian-7")     DISTRO="wheezy"  ;;
			"debian-8")     DISTRO="jessie"  ;;
			"debian-9")     DISTRO="stretch" ;;
			"debian-10")    DISTRO="buster"  ;; # 2020-05
			"ubuntu-16.04") DISTRO="xenial"  ;;
			"ubuntu-18.04") DISTRO="bionic"  ;; # 2020-04
			"ubuntu-20.04") DISTRO="focal"   ;; # 2021-01
		esac;

		# test that distro isnt unknown
		[ "${DISTRO}" = "unknown" ] && {
			Msg.error "This distribution is not supported: $OS_info"
		}
		Dye.fg.gray "This distribution is supported:" $( Dye.fg.gray.lite "$OS_info ($OS_path)" )

		# append to parent folder name the current distro infos
		t=~/linux.${OS_info}.${DISTRO}.${OS_arch}
		[ -d "$t" ] || { mv ~/linux* "$t"; OS_path="$t"; }

		# removing unneeded distros
		for x in $OS_path/distro-*; do
#			[ "$x" = "distro-${DISTRO}" ] || rm -rf "$x"
			[ "$x" = "$OS_path/distro-$DISTRO" ] || Dye.fg.gray removing "$x"
		done

		# sourcing all scripts
		for x in $OS_path/distro-${DISTRO}/fn_*; do
#			echo "$x"
			. "$x"
		done
		MyFILES=$OS_path/files-common
		MyDISTRO=$OS_path/distro-${DISTRO}/files
		is_available 'nginx' && HTTP_SERVER='nginx'
	}	# end detect_linux

	OS.menu() {
		# output the main menu on screen
		local k g c o;
		# need to create both arrays, as bash dont keep order on associative
		declare -a I	# indexed array
		declare -A H	# associative array
		# One time actions
		k=a_title;     I+=($k);H[$k]=" [ . $(Dye.fg.gray.lite One time actions) ----------------------------------------------- (in recommended order) -- ]"
		k=a_ssh;       I+=($k);H[$k]="   . ${cORNG}ssh${cNULL}         setup private key, shell, SSH on port ${cWITELITE}${SSHD_PORT}${cNULL}"
		k=a_deps;      I+=($k);H[$k]="   . ${cORNG}deps${cNULL}        check dependencies, update the base system, setup firewall"
		# Standalone utilities
		k=b_title;     I+=($k);H[$k]=" [ . $(Dye.fg.gray.lite Standalone utilities) ----------------------------------------- (in no particular order) -- ]"
		k=b_upgrade;   I+=($k);H[$k]="   . ${cORNG}upgrade${cNULL}     apt full upgrading of the system"
		k=b_password;  I+=($k);H[$k]="   . ${cORNG}password${cNULL}    print a random pw: \$1: length (6 to 32, 24), \$2: flag strong"
		k=b_iotest;    I+=($k);H[$k]="   . ${cORNG}iotest${cNULL}      perform the classic I/O test on the VPS"
		k=b_resolv;    I+=($k);H[$k]="   . ${cORNG}resolv${cNULL}      set ${cWITELITE}/etc/resolv.conf${cNULL} with public dns"
		k=b_mykeys;    I+=($k);H[$k]="   . ${cORNG}mykeys${cNULL}      set my authorized_keys, for me & backuppers"
		k=b_tz;        I+=($k);H[$k]="   . ${cORNG}tz${cNULL}          set server timezone to ${cWITELITE}${TIME_ZONE}${cNULL}"
		k=b_motd;      I+=($k);H[$k]="   . ${cORNG}motd${cNULL}        set a dynamic Message of the Day (motd)"
		# Main applications
		k=c_title;     I+=($k);H[$k]=" [ . ${cWITELITE}Main applications${cNULL} ---------------------------------------------- (in recommended order) -- ]"
		k=c_mailserver;I+=($k);H[$k]="   . ${cORNG}mailserver${cNULL}  full mailserver with postfix, dovecot & aliases"
		k=c_dbserver;  I+=($k);H[$k]="   . ${cORNG}dbserver${cNULL}    the DB server MariaDB, root pw in ${cWITELITE}~/.my.cnf${cNULL}"
		k=c_webserver; I+=($k);H[$k]="   . ${cORNG}webserver${cNULL}   webserver apache2 or nginx, with php, selfsigned cert, adminer"
		# Target system
		k=d_title;     I+=($k);H[$k]=" [ . ${cWITELITE}Target system${cNULL} ------------------------------------------------ (in no particular order) -- ]"
		k=d_dns;       I+=($k);H[$k]="   . ${cORNG}dns${cNULL}         bind9 DNS server with some related utilities"
		k=d_assp1;     I+=($k);H[$k]="   . ${cORNG}assp1${cNULL}       the AntiSpam SMTP Proxy version 1 (min 384ram 1core)"
		k=d_ispconfig; I+=($k);H[$k]="   . ${cORNG}ispconfig${cNULL}   historical Control Panel, support at ${cWITELITE}howtoforge.com${cNULL}"
		# Others applications
		k=e_title;     I+=($k);H[$k]=" [ . ${cWITELITE}Others applications${cNULL} ------------------------------------ (depends on main applications) -- ]"
		k=e_dumpdb;    I+=($k);H[$k]="   . ${cORNG}dumpdb${cNULL}      to backup all databases, or the one given in ${cWITELITE}\$1${cNULL}"
		k=e_roundcube; I+=($k);H[$k]="   . ${cORNG}roundcube${cNULL}   full featured imap web client"
		k=e_nextcloud; I+=($k);H[$k]="   . ${cORNG}nextcloud${cNULL}   on-premises file share and collaboration platform"
		k=e_espo;      I+=($k);H[$k]="   . ${cORNG}espo${cNULL}        EspoCRM full featured CRM web application"
		k=e_acme;      I+=($k);H[$k]="   . ${cORNG}acme${cNULL}        shell script for Let's Encrypt free SSL certificates"

		for k in "${I[@]}"; do	# iterating on indexed arr, that keep the given order
			[ "${k:0:2}" = "$g" ] || {
				[ -z "$c" ] || o+="${H[${g}title]}\n$c"
				c=; g="${k:0:2}"
			}
			is_available "menu_${k:2}" && c+="${H[$k]}\n"
		done
		echo -e " $( cmd date '+%F %T %z' ) ::" \
			$( Dye.fg.orange "$OS_info ($DISTRO) $OS_arch" ) \
			":: $OS_path\n$o${H[${g}title]}\n${c}" \
			"[ -------------------------------------------------------------------------------------------- ]"
	}	# end OS.menu


#	PROGRAM
#	main program to run
#	----------------------------------------------------------------------------
	detect_linux
	OS.menu "$@"
