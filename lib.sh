#!/bin/bash
# ==============================================================================
# companion library of the script for install Linux OSes
# ==============================================================================

#	DEFAULT VARIABLES
#	----------------------------------------------------------------------------
	ENV_product="unknown"				# linux distribution
	ENV_version="unknown"				# version of the distribution
	ENV_release="unknown"				# linux <product>-<version>
	ENV_codename="unknown"				# codename of the distribution
	ENV_arch="unknown"					# kernel architecture
	ENV_bits="unknown"					# kernel bits (numeric)
	ENV_files=""
	MyDISTRO=""

	TARGET="unknown"
	TIME_ZONE="Europe/Rome"
	SSHD_PORT="64128"
	IPT_RULES="ssh"

	HOST_NICK=$(command hostname -s)
	HOST_FQDN=$(command hostname -f)
	ROOT_MAIL="k-${HOST_NICK}@rete.us"
	LENC_MAIL="k-letsencrypt@rete.us"	# letsencrypt account email

	MAIL_NAME="${HOST_FQDN}"
	DB_ROOTPW=""
	ASSP_ADMINPW="zeroSpam4me"

	CERT_C="IT"
	CERT_ST="Reggio Emilia"
	CERT_L="Bagnolo in Piano"
	CERT_O="italmedia.net"
	CERT_OU="internet-server"
	CERT_CN="${HOST_FQDN}"
	CERT_E="${ROOT_MAIL}"

	HTTP_SERVER="apache2"
	ISP3_MULTISERVER="n"   # "n" or "y"
	ISP3_MASTERHOST=""     # fqdn of the master ispconfig multiserver db, or empty
	ISP3_MASTERUSER="root" # username of the master db, usually root
	ISP3_MASTERPASS=""     # password of the master db, if empty will be asked

	# -- bash colors -----------------------------------------------------------
	cNULL='\e[0m'
	cBLAK='\e[0;30m'
	cREDD='\e[0;31m'
	cGREN='\e[0;32m'
	cYELW='\e[0;33m'
	cBLUE='\e[0;34m'
	cPURP='\e[0;35m'
	cCYAN='\e[0;36m'
	cGRAY='\e[0;37m'
	cORNG='\e[38;5;215m'
	cBLAKLITE='\e[1;30m'
	cREDDLITE='\e[1;31m'
	cGRENLITE='\e[1;32m'
	cYELWLITE='\e[1;33m'
	cBLUELITE='\e[1;34m'
	cPURPLITE='\e[1;35m'
	cCYANLITE='\e[1;36m'
	cWITELITE='\e[1;37m'

	Dye.as() {
		# output painted text
		# $1 num : type (default 0, dark)
		# $2 num : color (default 37, gray)
		# $3 text: message to colorize
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
	Dye.fg.white()       { Dye.as 1 37 "$@"; };
	Dye.fg.orange()      { Dye.as "38;5" 214 "$@"; };



#	MESSENGERS
#	----------------------------------------------------------------------------
	Msg.debug() { Dye.as 1 32 "$@"; }					# green lite
	Msg.info()  { Dye.as 1 36 "$@"; }					# cyan lite
	Msg.warn()  { Dye.as 1 33 "$@"; }					# yellow lite
	Msg.error() { Dye.as 1 31 "ERROR: $@"; exit 1; }	# red lite



#	FUNCTIONS
#	companion functions for the entire system
#	----------------------------------------------------------------------------
	Arg.expect() {
		# helper function for verifying args in functions
		# expects: variable number of arguments ( $1 [, $2 [, $3 ... ]] )
		local i=1
		for (( ; i<=$#; i++ )); do
			[ -z "${!i}" ] \
				&& Msg.warn "Missing argument #$i to ${FUNCNAME[1]}()" \
				&& return 1
		done
		return 0
	};


	cmd() {
		# try to run the real command, not an aliased version
		# on missing command, or error, it return silently
		Arg.expect "$1" || return 0
		#[ -n "$1" ] || return 0
		local c="$( command -v $1 )"
		shift && [ -n "$c" ] && "$c" "$@"
	}	# end cmd


	Date.fmt() {
		# return a formatted date/time, providing a custom default
		echo $(cmd date ${@:-'+%F %T'})
	}	# end Date.fmt


	numeric_version() {
		# return the cleaned numeric version of a program
		cmd awk -F. '{ printf("%d.%d.%d\n",$1,$2,$3) }' <<< "${@}"
	}	# end numeric_version


	drop_folder() {
		# if directory exists then delete it
		# $1: path to folder
		# $2: optional message
		[ -d "${1}" ] && {
			[ -n "${2}" ] && echo -e "${2}"
			cmd rm -rf "${1}"
		}
	}	# end drop_folder


	clean_me_up() {
		# if directory exists then delete it
		drop_folder "${1}" "Cleaning up the lock folder: ${cWITELITE}${1}${cNULL}"
	}	# end clean_me_up


	lock_me_baby() {
		# give lockdir the name in arg 1, or a default one
		local LOCKDIR=/tmp/${1-myapp}
		# if directory exists exit here
		[ -d "${LOCKDIR}" ] && {
			Msg.warn "Job is already running with pid: $(< ${LOCKDIR}/PID)"
			exit 6
		}
		# this is a new instance
		echo -e "Locking the job in: ${cWITELITE}${LOCKDIR}${cNULL}";
		# create folder & store the pid
		mkdir -p ${LOCKDIR}
		echo $$ > ${LOCKDIR}/PID
		# then set traps to cleanup upon script termination
		# ref http://www.shelldorado.com/goodcoding/tempfiles.html
		trap "clean_me_up ${LOCKDIR}" 0
		trap "exit 2" 1 2 3 13 15
	}	# end lock_me_baby


	backup_file() {
		# if backup exists do nothing
		[ -e "${1}.backup" ] && return
		# if original is not empty, copy it to backup
		[ -s "${1}" ] && cp "${1}" "${1}.backup"
	}	# end backup_file


	sed_copy() {
		# copy a file $1 to destination $2 forcing unix EOLs
		backup_file "${2}"					# do backup first
		sed -e 's|\r||g' "${1}" > "${2}"	# copy forcing unix EOLs
	}	# end sed_copy


	is_symlink() {
		# exits with 0 (success) if symlink is valid, or 1 if broken/missing
		# $1: path to a symlink
		[ -L "$1" ] && [ -e "$1" ]
	}	# end is_symlink


	File.pick() {
		# return the full path to a common file, looking first into the distro/files 
		# $1 relative path to search
		Arg.expect "$1" && {
			cmd readlink -e $ENV_distro/files/$1 \
				|| cmd readlink -e $ENV_files/$1 \
				|| return 1
		}
		return 0
	}	# end File.pick


	my_path() {
		# returns: full path from one of MyDISTRO / ENV_files, or an empty string
		# $1: relative path to find
		cmd readlink -e ${MyDISTRO}/${1} || readlink -e ${ENV_files}/${1} 2>/dev/null
	}	# end my_path


	do_copy() {
		# copy a single file from one of MyDISTRO / ENV_files to destination path
		# $1: myFileName
		# $2: destinationFullPath
		local F=$(my_path ${1-missing}) D=${2}
		[ -n "${F}" ] && {
			[ -d "${D}" ] && D="${D}/${1}"	# build destination
			sed_copy "${F}" "${D}"			# backup & copy
		}
	}	# end do_copy


	copy_to() {
		# copy to the single destination folder in $1, one or more files in $@
		# that can comes exclusively from one of MyDISTRO ENV_files
		[ -d "${1}" ] || return

		local ALT C A F D=$(cmd readlink -e ${1})
		shift

		# iterating containers
		for C in ${MyDISTRO} ${ENV_files}; do

			# iterating arguments
			for A in "${@}"; do

				# iterating files
				for F in $(find ${C} -wholename "*${A}"); do
					sed_copy "${F}" "${D}/$(basename ${F})"
					ALT=1
				done
			done
			[ -z "${ALT}" ] || break
		done
	}	# end copy_to


	is_installed() {
		# > /my/file  redirects stdout to /my/file
		# 1> /my/file redirects stdout to /my/file
		# 2> /my/file redirects stderr to /my/file
		# &> /my/file redirects stdout and stderr to /my/file

		# redirects stderr to the black hole
		[ -n "${1}" ] && dpkg -l "${1}" 2> /dev/null | grep -q ^ii
	}	# end is_installed


	is_available() {
		# test 1st argument for: not empty & callable
		[ -n "${1}" ] && command -v "${1}" >/dev/null 2>&1
	}	# end is_available


	pkg_update() {
		# the "apt-get update", to run before install any package
		dpkg --configure -a	# in case apt is in a bad state

		# if an argument is given then forcing run apt-get
		[ -z "${1}" ] || {
			Msg.info "Forcing packages list to update..."
			DOCLEANAPT=
		}

		[ -z "${DOCLEANAPT}" ] && {
			DOCLEANAPT=1		# signal to do apt cleanup on exit
			apt-get -qy update || {
				Msg.error "Some errors occurred executing 'apt-get update'. Try again later..."
			}
		}
	}	# end pkg_update


	is_installable() {
		# test 1st argument for: not empty & package installable
		pkg_update	# update packages lists
		[ -n "${1}" ] && [ $(apt-cache search "^${1}$" | wc -l) -gt 0 ] && return
		return 1
	}	# end is_installable


	menu_upgrade() {
		Msg.info "Upgrading system packages for ${ENV_os}..."
		pkg_update	# update packages lists

		# do the apt-get upgrade
		export DEBIAN_FRONTEND=noninteractive
		apt-get -qy dist-upgrade
	}	# end menu_upgrade


	pkg_install() {
		pkg_update	# update packages lists
		export DEBIAN_FRONTEND=noninteractive
		apt-get -qy \
			-o Dpkg::Options::="--force-confdef" \
			-o Dpkg::Options::="--force-confnew" \
			install "${@}"
	}	# end pkg_install


	pkg_require() {
		local T
		for T in "${@}"
			do is_installed "${T}" || {
				Msg.info "Installing required packages: ${@}"
				pkg_install "${@}"
				break
			}
		done
	}	# end pkg_require


	pkg_purge() {
		# remove a single package via apt-get
		[ -z "${1}" ] && return

		# it can be a command
		local CMD=$(command -v $1)

		# detect package from command
		CMD=${CMD:+$(dpkg -S "${CMD}" 2> /dev/null)}

		# do the real deletion
		is_installed "${CMD%:*}" && {
			export DEBIAN_FRONTEND=noninteractive
			apt-get -qy purge --auto-remove "${CMD%:*}"
			Msg.info "Removing package '${CMD%:*}' (from '${1}') completed!"
			return
		}

		Msg.warn "No package for '${1}' is installed"
	}	# end pkg_purge


	down_load() {
		# download via wget, returning an error on failure
		# $1 url
		# $2 destination name

		# we need exactly 2 arguments
		[ $# == 2 ] || {
			Msg.info "Missing arguments for downloading, exiting here..."
			exit
		}

		pkg_require wget
		wget -nv --no-check-certificate ${1} -O ${2} || {
			Msg.info "Download failed ( ${2} ), exiting here..."
			exit
		}
	}	# end down_load


	menu_password() {
		# generate a random password (min 6 max 32 chars)
		# $1 number of characters (defaults to 24)
		# $2 flag for strong password (defaults no)
		local CHR="[:alnum:]" LEN=$(cmd awk '{print int($1)}' <<< ${1:-24})

		# constrain number of characters
		LEN=$(( LEN > 31 ? 32 : LEN < 7 ? 6 : LEN ))

		# add special chars for strong password
		[ -n "${2}" ] && CHR="!#\$%&*+\-.:<=>?@[]^~${CHR}"

		echo $(cmd tr -dc "${CHR}" < /dev/urandom | head -c ${LEN})
	}	# end menu_password


	menu_iotest() {
		# classic disk I/O test
		Msg.info "Performing classic I/O test..."
		cd ~
		cmd dd if=/dev/zero of=~/tmpf bs=64k count=16k conv=fdatasync && rm -rf ~/tmpf
	}	# end menu_iotest


	done_deps() {
		# test that the step "menu_deps" was already executed

		# simply check that /etc/apt/apt.conf.d/99norecommend exists
		[ -f "/etc/apt/apt.conf.d/99norecommend" ] || {
			Msg.warn "Need to execute '$(cmd basename "$0") deps' step before..."
			return 1
		}
	}	# end done_deps


	port_validate() {
		# set port in $1 to be strictly numeric & in range
		local T L P=$(awk '{print int($1)}' <<< ${1:-22})
		(( P == 22 )) || {
			# limit min & max range
			P=$(( P > 65534 ? 65535 : P < 1025 ? 1024 : P ))
			# exclude net.ipv4.ip_local_port_range (32768-60999)
			T=$(command sysctl -e -n net.ipv4.ip_local_port_range)
			L=$(awk '{print int($1)}' <<< ${T})
			T=$(awk '{print int($2)}' <<< ${T})
			P=$(( P < L ? P : P > T ? P : 64128 ))
		}
		echo ${P}
	}	# end port_validate


	php_version() {
		# return the dotted number of the cli version of PHP
		# $1 = word to specify the wanted result like this
		# 7.2.24 = major will return 7, minor will return 7.2, otherwise 7.2.24
		local V=$(cmd php -v | grep -oP 'PHP [\d\.]+' | awk '{print $2}')
		[ "${1}" = "major" ] && V=$(cmd awk -F. '{print $1}' <<< "${V}")
		[ "${1}" = "minor" ] && V=$(cmd awk -F. '{print $1"."$2}' <<< "${V}")
		echo "${V}"
	}	# end php_version


	has_ispconfig() {
		# exits with 0 (success) if ispconfig is installed
		[ -s '/usr/local/ispconfig/server/lib/config.inc.php' ]
	}	# end has_ispconfig



#	MAIN MENU
#	----------------------------------------------------------------------------

	Env.clean() {
		# do apt cleanup if $1 is not empty
		[ -n "${DOCLEANAPT}" ] && {
			unset DOCLEANAPT
			apt-get -qy purge				# remove packages and config files
			apt-get -qy autoremove			# remove unused packages automatically
			apt-get -qy autoclean			# erase old downloaded archive files
			apt-get -qy clean				# erase downloaded archive files
			rm -rf /var/lib/apt/lists/*		# delete the entire cache
		}
	}	# end Env.clean


	ENV.init() {
		# initializes the environment
		# no arguments expected

		# user must be root (id == 0)
		(( $(cmd id -u) )) && {
			Msg.error "This script must be run by the user: ${cWITELITE}root${cNULL}"
		}
		local x t

		# test the availability of some required commands
		for x in awk apt-get cat cd cp debconf-set-selections dpkg \
			dpkg-reconfigure find grep head mkdir mv perl rm sed tr;
		do
			is_available "$x" || Msg.error "Missing command: $x"
		done

		# detect OS info (ENV_product, ENV_version, ENV_codename)
		# thanks to Mikel (http://unix.stackexchange.com/users/3169/mikel) for idea
		if [ -f /etc/lsb-release ]; then
			. /etc/lsb-release
			ENV_product=${DISTRIB_ID,,}			# lowercase debian, ubuntu, ...
			ENV_version=${DISTRIB_RELEASE,,}	# lowercase 9, 18.04, ...
		elif [ -f /etc/os-release ]; then
			. /etc/os-release
			ENV_product=${ID,,}					# lowercase debian, ubuntu, ...
			ENV_version=${VERSION_ID,,}			# lowercase 9, 18.04, ...
		elif [ -f /etc/issue.net ]; then
			t=$(head -1 /etc/issue.net)
			ENV_product=$(awk '{print $1}' <<< ${t,,})
			ENV_version=$(perl -pe '($_)=/(\d+([.]\d+)+)/' <<< ${t,,})
		fi;

		# setup some environment variables
		ENV_release="${ENV_product}-${ENV_version}"
		ENV_arch=$( cmd uname -m )
		ENV_bits=$( cmd getconf LONG_BIT )

		case $ENV_release in
		#	"debian-7")     ENV_codename="wheezy"  ;;
			"debian-8")     ENV_codename="jessie"  ;;
			"debian-9")     ENV_codename="stretch" ;;
			"debian-10")    ENV_codename="buster"  ;; # 2020-05
			"ubuntu-16.04") ENV_codename="xenial"  ;;
			"ubuntu-18.04") ENV_codename="bionic"  ;; # 2020-04
			"ubuntu-20.04") ENV_codename="focal"   ;; # 2021-01
		esac;

		# control that release isnt unknown
		[ "$ENV_codename" = "unknown" ] && {
			Msg.error "This distribution is not supported: $ENV_release"
		}

		# append to parent folder name the discovered infos
		t=${ENV_dir%/*}/linux.${ENV_release}.${ENV_codename}.${ENV_arch}
		[ -d "$t" ] || {
			mv ~/linux* "$t"
			ENV_dir="$t"
		}

		# setup other environment variables
		ENV_os="$ENV_release ($ENV_codename)"
		ENV_files="$ENV_dir/files-common"
		ENV_distro="$ENV_dir/distro-$ENV_codename"
		MyDISTRO="$ENV_distro/files"

		# removing unneeded distros
		for x in $ENV_dir/distro-*; do
			[ "$x" = "$ENV_distro" ] || rm -rf "$x"
		done

		# sourcing all scripts
		for x in $ENV_distro/fn_*
			do . "$x"
		done

		is_available 'nginx' && HTTP_SERVER='nginx'
	}	# end ENV.init


	OS.menu() {
		# output the main menu on screen
		local k g c o;
		declare -a I;	# indexed array
		declare -A U	# associative array
		# One time actions
		k=a.title;     I+=($k);U[$k]=" [ . ${cWITELITE}One time actions${cNULL} ---------------------------------------------- (in recommended order) -- ]"
		k=a.ssh;       I+=($k);U[$k]="   . ${cORNG}ssh${cNULL}         setup private key, shell, SSH on port ${cWITELITE}${SSHD_PORT}${cNULL}"
		k=a.deps;      I+=($k);U[$k]="   . ${cORNG}deps${cNULL}        check dependencies, update the base system, setup firewall"
		# Standalone utilities
		k=b.title;     I+=($k);U[$k]=" [ . ${cWITELITE}Standalone utilities${cNULL} ---------------------------------------- (in no particular order) -- ]"
		k=b.upgrade;   I+=($k);U[$k]="   . ${cORNG}upgrade${cNULL}     apt full upgrading of the system"
		k=b.password;  I+=($k);U[$k]="   . ${cORNG}password${cNULL}    print a random pw: \$1: length (6 to 32, 24), \$2: flag strong"
		k=b.iotest;    I+=($k);U[$k]="   . ${cORNG}iotest${cNULL}      perform the classic I/O test on the VPS"
		k=b.resolv;    I+=($k);U[$k]="   . ${cORNG}resolv${cNULL}      set ${cWITELITE}/etc/resolv.conf${cNULL} with public dns"
		k=b.mykeys;    I+=($k);U[$k]="   . ${cORNG}mykeys${cNULL}      set my authorized_keys, for me & backuppers"
		k=b.tz;        I+=($k);U[$k]="   . ${cORNG}tz${cNULL}          set server timezone to ${cWITELITE}${TIME_ZONE}${cNULL}"
		k=b.motd;      I+=($k);U[$k]="   . ${cORNG}motd${cNULL}        set a dynamic Message of the Day (motd)"
		# Main applications
		k=c.title;     I+=($k);U[$k]=" [ . ${cWITELITE}Main applications${cNULL} --------------------------------------------- (in recommended order) -- ]"
		k=c.mailserver;I+=($k);U[$k]="   . ${cORNG}mailserver${cNULL}  full mailserver with postfix, dovecot & aliases"
		k=c.dbserver;  I+=($k);U[$k]="   . ${cORNG}dbserver${cNULL}    the DB server MariaDB, root pw in ${cWITELITE}~/.my.cnf${cNULL}"
		k=c.webserver; I+=($k);U[$k]="   . ${cORNG}webserver${cNULL}   webserver apache2 or nginx, with php, selfsigned cert, adminer"
		# Target system
		k=d.title;     I+=($k);U[$k]=" [ . ${cWITELITE}Target system${cNULL} ----------------------------------------------- (in no particular order) -- ]"
		k=d.dns;       I+=($k);U[$k]="   . ${cORNG}dns${cNULL}         bind9 DNS server with some related utilities"
		k=d.assp1;     I+=($k);U[$k]="   . ${cORNG}assp1${cNULL}       the AntiSpam SMTP Proxy version 1 (min 384ram 1core)"
		k=d.ispconfig; I+=($k);U[$k]="   . ${cORNG}ispconfig${cNULL}   historical Control Panel, support at ${cWITELITE}howtoforge.com${cNULL}"
		# Others applications
		k=e.title;     I+=($k);U[$k]=" [ . ${cWITELITE}Others applications${cNULL} ----------------------------------- (depends on main applications) -- ]"
		k=e.dumpdb;    I+=($k);U[$k]="   . ${cORNG}dumpdb${cNULL}      to backup all databases, or the one given in ${cWITELITE}\$1${cNULL}"
		k=e.roundcube; I+=($k);U[$k]="   . ${cORNG}roundcube${cNULL}   full featured imap web client"
		k=e.nextcloud; I+=($k);U[$k]="   . ${cORNG}nextcloud${cNULL}   on-premises file share and collaboration platform"
		k=e.espo;      I+=($k);U[$k]="   . ${cORNG}espo${cNULL}        EspoCRM full featured CRM web application"
		k=e.acme;      I+=($k);U[$k]="   . ${cORNG}acme${cNULL}        shell script for Let's Encrypt free SSL certificates"

		for k in "${I[@]}"; do
			[ "${k:0:2}" = "${g}" ] || {
				[ -z "${c}" ] || o+="${U[${g}title]}\n${c}"
				c=; g="${k:0:2}"
			}
			is_available "menu_${k:2}" && c+="${U[$k]}\n"
		done
		echo -e " $(cmd date '+%F %T %z') :: ${cORNG}${ENV_os} ${ENV_arch}${cNULL}" \
			":: ${ENV_dir}\n${o}${U[${g}title]}\n${c}" \
			"[ ------------------------------------------------------------------------------------------- ]"
	}	# end OS.menu
