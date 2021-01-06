#!/bin/bash
# companion library of OpenVZ VPS setup script for installing Debian like OSes

# ------------------------------------------------------------------------------
# DEFAULT VARIABLES
# ------------------------------------------------------------------------------

LINUX="unknown"
VERSION="unknown"
DISTRO="unknown"					# pretty name of the linux distribution
ARCH=$(command uname -m)
XBIT=$(command getconf LONG_BIT)
OS="unknown"
MyFILES=""
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

HTTP_SERVER="apache"
ISP3_MULTISERVER="n"   # "n" or "y"
ISP3_MASTERHOST=""     # fqdn of the master ispconfig multiserver db, or empty
ISP3_MASTERUSER="root" # username of the master db, usually root
ISP3_MASTERPASS=""     # password of the master db, if empty will be asked

# -- bash colors ---------------------------------------------------------------
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



# ------------------------------------------------------------------------------
# MESSAGERS
# ------------------------------------------------------------------------------

msg_error() {
	echo -e "${cREDDLITE}ERROR: $@${cNULL}"; exit 1;
}
msg_alert() {
	echo -e "${cYELWLITE}$@${cNULL}";
}
msg_info() {
	echo -e "${cCYANLITE}$@${cNULL}";
}
msg_notice() {
	echo -e "${cGRENLITE}$@${cNULL}";
}



# ------------------------------------------------------------------------------
# UTILITIES
# ------------------------------------------------------------------------------

cmd() {
	# run a command without returning errors
	[ -n "${1}" ] || return 0
	local c="$(command -v ${1})"
	shift && [ -n "${c}" ] && ${c} "${@}"
};	# end cmd

# ------------------------------------------------------------------------------

date_fmt() {
	echo $(cmd date "${@-+'%F %T'}")	# formatted datetime
};	# end date_fmt

# ------------------------------------------------------------------------------

numeric_version() {
	# return the cleaned numeric version of a program
	cmd awk -F. '{ printf("%d.%d.%d\n",$1,$2,$3) }' <<< "${@}"
}	# end numeric_version

# ------------------------------------------------------------------------------

drop_folder() {
	# if directory exists then delete it
	# $1: path to folder
	# $2: optional message
	[ -d "${1}" ] && {
		[ -n "${2}" ] && echo -e "${2}"
		cmd rm -rf "${1}"
	}
};	# end drop_folder

# ------------------------------------------------------------------------------

clean_me_up() {
	# if directory exists then delete it
	drop_folder "${1}" "Cleaning up the lock folder: ${cWITELITE}${1}${cNULL}"
};	# end clean_me_up

# ------------------------------------------------------------------------------

lock_me_baby() {
	# give lockdir the name in arg 1, or a default one
	local LOCKDIR=/tmp/${1-myapp}
	# if directory exists exit here
	[ -d "${LOCKDIR}" ] && {
		msg_alert "Job is already running with pid: $(< ${LOCKDIR}/PID)"
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
};	# end lock_me_baby

# ------------------------------------------------------------------------------

backup_file() {
	# if backup exists do nothing
	[ -e "${1}.backup" ] && return
	# if original is not empty, copy it to backup
	[ -s "${1}" ] && cp "${1}" "${1}.backup"
}	# end backup_file

# ------------------------------------------------------------------------------

sed_copy() {
	# copy a file $1 to destination $2 forcing unix EOLs
	backup_file "${2}"					# do backup first
	sed -e 's|\r||g' "${1}" > "${2}"	# copy forcing unix EOLs
}	# end sed_copy

# ------------------------------------------------------------------------------

is_symlink() {
	# exits with 0 if symlink is valid, or with 1 if it is broken
	# $1: path to a symlink
	[ -L "${1}" ] && [ -e "${1}" ]
}	# end is_symlink

# ------------------------------------------------------------------------------

my_path() {
	# returns: full path from one of MyDISTRO / MyFILES, or an empty string
	# $1: relative path to find
	cmd readlink -e ${MyDISTRO}/${1} || readlink -e ${MyFILES}/${1} 2>/dev/null
};	# end my_path

# ------------------------------------------------------------------------------

do_copy() {
	# copy a single file from one of MyDISTRO / MyFILES to destination path
	# $1: myFileName
	# $2: destinationFullPath
	local F=$(my_path ${1-missing}) D=${2}
	[ -n "${F}" ] && {
		[ -d "${D}" ] && D="${D}/${1}"	# build destination
		sed_copy "${F}" "${D}"			# backup & copy
	}
}	# end do_copy

# ------------------------------------------------------------------------------

copy_to() {
	# copy to the single destination folder in $1, one or more files in $@
	# that can comes exclusively from one of MyDISTRO MyFILES
	[ -d "${1}" ] || return

	local ALT C A F D=$(cmd readlink -e ${1})
	shift

	# iterating containers
	for C in ${MyDISTRO} ${MyFILES}; do

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

# ------------------------------------------------------------------------------

is_installed() {
	# > /my/file  redirects stdout to /my/file
	# 1> /my/file redirects stdout to /my/file
	# 2> /my/file redirects stderr to /my/file
	# &> /my/file redirects stdout and stderr to /my/file

	# redirects stderr to the black hole
	[ -n "${1}" ] && dpkg -l "${1}" 2> /dev/null | grep -q ^ii
}	# end is_installed

# ------------------------------------------------------------------------------

is_available() {
	# test 1st argument for: not empty & callable
	[ -n "${1}" ] && command -v "${1}" >/dev/null 2>&1
}	# end is_available

# ------------------------------------------------------------------------------

pkg_update() {
	# the "apt-get update", to run before install any package
	dpkg --configure -a	# in case apt is in a bad state

	# if an argument is given then forcing run apt-get
	[ -z "${1}" ] || {
		msg_info "Forcing packages list to update..."
		DOCLEANAPT=
	}

	[ -z "${DOCLEANAPT}" ] && {
		DOCLEANAPT=1		# signal to do apt cleanup on exit
		apt-get -qy update || {
			msg_error "Some errors occurred executing 'apt-get update'. Try again later..."
		}
	}
}	# end pkg_update

# ------------------------------------------------------------------------------

is_installable() {
	# test 1st argument for: not empty & package installable
	pkg_update	# update packages lists
	[ -n "${1}" ] && [ $(apt-cache search "^${1}$" | wc -l) -gt 0 ] && return
	return 1
}	# end is_installable

# ------------------------------------------------------------------------------

menu_upgrade() {
	msg_info "Upgrading system packages for ${OS} (${DISTRO})..."
	pkg_update	# update packages lists

	# do the apt-get upgrade
	export DEBIAN_FRONTEND=noninteractive
	apt-get -qy dist-upgrade
}	# end menu_upgrade

# ------------------------------------------------------------------------------

pkg_install() {
	pkg_update	# update packages lists
	export DEBIAN_FRONTEND=noninteractive
	apt-get -qy \
		-o Dpkg::Options::="--force-confdef" \
		-o Dpkg::Options::="--force-confnew" \
		install "${@}"
}	# end pkg_install

# ------------------------------------------------------------------------------

pkg_require() {
	local T
	for T in "${@}"
		do is_installed "${T}" || {
			msg_info "Installing required packages: ${@}"
			pkg_install "${@}"
			break
		}
	done
}	# end pkg_require

# ------------------------------------------------------------------------------

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
		msg_info "Removing package '${CMD%:*}' (from '${1}') completed!"
		return
	}

	msg_alert "No package for '${1}' is installed"
}	# end pkg_purge

# ------------------------------------------------------------------------------

down_load() {
	# download via wget, returning an error on failure
	# $1 url
	# $2 destination name

	# we need exactly 2 arguments
	[ $# == 2 ] || {
		msg_info "Missing arguments for downloading, exiting here..."
		exit
	}

	pkg_require wget
	wget -nv --no-check-certificate ${1} -O ${2} || {
		msg_info "Download failed ( ${2} ), exiting here..."
		exit
	}
}	# end down_load

# ------------------------------------------------------------------------------

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

# ------------------------------------------------------------------------------

menu_iotest() {
	# classic disk I/O test
	msg_info "Performing classic I/O test..."
	cd ~
	cmd dd if=/dev/zero of=~/tmpf bs=64k count=16k conv=fdatasync && rm -rf ~/tmpf
}	# end menu_iotest

# ------------------------------------------------------------------------------

done_deps() {
	# test that the step "menu_deps" was already executed

	# simply check that /etc/apt/apt.conf.d/99norecommend exists
	[ -f "/etc/apt/apt.conf.d/99norecommend" ] || {
		msg_alert "Need to execute '$(cmd basename "$0") deps' step before..."
		return 1
	}
}	# end done_deps

# ------------------------------------------------------------------------------

php_version() {
	# return the dotted number of the cli version of PHP
	# $1 = word to specify the wanted result like this
	# 7.2.24 = major will return 7, minor will return 7.2, otherwise 7.2.24
	local V=$(cmd php -v | grep -oP 'PHP [\d\.]+' | awk '{print $2}')
	[ "${1}" = "major" ] && V=$(cmd awk -F. '{print $1}' <<< "${V}")
	[ "${1}" = "minor" ] && V=$(cmd awk -F. '{print $1"."$2}' <<< "${V}")
	echo "${V}"
}	# end php_version

# ------------------------------------------------------------------------------

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



# ------------------------------------------------------------------------------
# MAIN MENU
# ------------------------------------------------------------------------------

clean_up() {
	# do apt cleanup if $1 is not empty
	[ -n "${DOCLEANAPT}" ] && {
		unset DOCLEANAPT
		apt-get -qy purge				# remove packages and config files
		apt-get -qy autoremove			# remove unused packages automatically
		apt-get -qy autoclean			# erase old downloaded archive files
		apt-get -qy clean				# erase downloaded archive files
		rm -rf /var/lib/apt/lists/*		# delete the entire cache
	}
}	# end clean_up

# ------------------------------------------------------------------------------

detect_linux() {
	# detect OS info (LINUX, VERSION, DISTRO)
	# thanks to Mikel (http://unix.stackexchange.com/users/3169/mikel) for idea

	# user must be root (id == 0)
	(( $(cmd id -u) )) && {
		msg_error "This script must be run by the user: ${cWITELITE}root${cNULL}"
	}
	local X T

	# test the presence of some very basic software
	for X in awk apt-get cat cd cp debconf-set-selections dpkg \
		dpkg-reconfigure find grep head mkdir mv perl rm sed tr;
	do
		is_available "${X}" || T+=", ${X}"
	done

	[ -z "${T}" ] || {
		msg_error "Some mandatory commands are missing: ${cWITELITE}${T:2}${cNULL}"
	}

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
		T=$(head -1 /etc/issue.net)
		LINUX=$(awk '{print $1}' <<< ${T,,})
		VERSION=$(perl -pe '($_)=/(\d+([.]\d+)+)/' <<< ${T,,})
	fi;

	# assigning distribution pretty name
	OS="${LINUX}-${VERSION}"

	case ${OS} in
	#	"debian-7")     DISTRO="wheezy"  ;;
		"debian-8")     DISTRO="jessie"  ;;
		"debian-9")     DISTRO="stretch" ;;
		"debian-10")    DISTRO="buster"  ;; # 2020-05
		"ubuntu-16.04") DISTRO="xenial"  ;;
		"ubuntu-18.04") DISTRO="bionic"  ;; # 2020-04
	esac;

	# test that distro isnt unknown
	[ "${DISTRO}" = "unknown" ] && {
		msg_error "This distribution is not supported ( ${LINUX} : ${VERSION} )"
	}

	# append to parent folder name the current distro infos
	T=~/linux.${OS}.${DISTRO}.${ARCH}
	[ -d ${T} ] || mv ~/linux* ${T}
	cd ${T}

	# removing unneeded distros
	for X in distro-*; do [ "${X}" = "distro-${DISTRO}" ] || rm -rf ${X}; done

	# sourcing all scripts
	for X in distro-${DISTRO}/fn_*; do . ${X}; done
	MyFILES=$(pwd)/files-common
	MyDISTRO=$(pwd)/distro-${DISTRO}/files
	is_available 'nginx' && HTTP_SERVER='nginx'
}	# end detect_linux

# ------------------------------------------------------------------------------

help_menu() {
	# display the main menu on screen
	echo -e " $(date '+%Y-%m-%d %T %z') :: ${cORNG}${OS} (${DISTRO}) ${ARCH}${cNULL} :: ${MyDir}
 [ . ${cWITELITE}Basic menu options${cNULL} ---------------------------- (in recommended order) -- ]
   . ${cORNG}ssh${cNULL}         setup private key, shell, SSH on port ${cWITELITE}${SSHD_PORT}${cNULL}
   . ${cORNG}deps${cNULL}        check dependencies, update the base system, setup firewall
   . ${cORNG}resolv${cNULL}      set ${cWITELITE}/etc/resolv.conf${cNULL} with public dns
   . ${cORNG}mykeys${cNULL}      set my authorized_keys, for me & backuppers
   . ${cORNG}tz${cNULL}          set server timezone to ${cWITELITE}${TIME_ZONE}${cNULL}
   . ${cORNG}motd${cNULL}        set a dynamic Message of the Day (motd)
 [ . ${cWITELITE}Standalone utilities${cNULL} ------------------------ (in no particular order) -- ]
   . ${cORNG}upgrade${cNULL}     apt full upgrading of the system
   . ${cORNG}password${cNULL}    print a random pw: \$1: length (6 to 32, 24), \$2: flag strong
   . ${cORNG}iotest${cNULL}      perform the classic I/O test on the VPS
 [ . ${cWITELITE}Main applications${cNULL} ----------------------------- (in recommended order) -- ]
   . ${cORNG}mailserver${cNULL}  full mailserver with postfix, dovecot & aliases
   . ${cORNG}dbserver${cNULL}    the DB server, MariaDB or MySQL, root pw in ${cWITELITE}~/.my.cnf${cNULL}
   . ${cORNG}webserver${cNULL}   webserver with apache, php, adminer, pureftpd
 [ . ${cWITELITE}Target system${cNULL} ------------------------------- (in no particular order) -- ]
   . ${cORNG}dns${cNULL}         bind9 DNS server with some related utilities
   . ${cORNG}assp1${cNULL}       the AntiSpam SMTP Proxy version 1 (min 384ram 1core)
   . ${cORNG}ispconfig${cNULL}   the magic Control Panel of the nice guys at howtoforge.com
 [ . ${cWITELITE}Others applications${cNULL} ------------------- (depends on main applications) -- ]
   . ${cORNG}acme${cNULL}        shell script for Let's Encrypt free certificate client
   . ${cORNG}roundcube${cNULL}   full featured imap web client
   . ${cORNG}nextcloud${cNULL}   owncloud alternative of the file sharing system
   . ${cORNG}espo${cNULL}        EspoCRM full featured CRM webapplication
 -------------------------------------------------------------------------------"
}	# end help_menu
