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
	Dye.as() {
		# output painted text
		# $1 num : type (default 0, dark)
		# $2 num : color (default 37, gray)
		# $3 text: message to colorize
		echo -e "\e[${1:-0};${2:-37}m${@:3}\e[0m";
	}
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
		local c="$( command -v $1 )"
		shift && [ -n "$c" ] && "$c" "$@"
	}	# end cmd


	Date.fmt() {
		# return a formatted date/time, providing a custom default
		echo -e $(cmd date "${@-+'%F %T'}")
	}	# end Date.fmt


	numeric_version() {
		# return the cleaned numeric version of a program
		cmd awk -F. '{ printf("%d.%d.%d\n",$1,$2,$3) }' <<< "$@"
	}	# end numeric_version


	Dir.delete() {
		# if directory exists then delete it
		# $1: path to folder
		# $2: optional message
		Arg.expect "$1" && [ -d "$1" ] && {
			[ -n "$2" ] && echo -e "${@:2}"
			cmd rm -rf "$1"
		}
	}	# end Dir.delete


	Sess.clean() {
		# try to delete the folder in $1
		Dir.delete "$1" "Cleaning up the lock folder:" $( Dye.fg.white "$1" )
	}	# end Sess.clean


	Sess.lock() {
		# give lockdir the name in $1, or a default one
		local d=/tmp/${1-myapp}
		# if directory exists exit here
		[ -d "$d" ] && {
			Msg.warn "Job is already running with pid: $(< $d/PID)"
			exit 6
		}
		# this is a new instance
		echo -e "Locking the job in:" $( Dye.fg.white "$d" )
		# create folder & store the pid
		mkdir -p "$d"
		echo $$ > $d/PID
		# then set traps to cleanup upon script termination
		# ref http://www.shelldorado.com/goodcoding/tempfiles.html
		trap "Sess.clean $d" 0
		trap "exit 2" 1 2 3 13 15
	}	# end Sess.lock


	File.backup() {
		# if backup exists do nothing
		Arg.expect "$1" && [ -e "${1}.backup" ] && return
		# if original is not empty, copy it to backup
		[ -s "$1" ] && cp "$1" "${1}.backup"
	}	# end File.backup


	File.recopy() {
		# copy the file in $1 to the destination in $2, forcing unix EOLs
		File.backup "$2"				# do backup first
		sed -e 's|\r||g' "$1" > "$2"	# copy forcing unix EOLs
	}	# end File.recopy


	File.islink() {
		# exits with 0 (success) if symlink is valid, or 1 if broken/missing
		# $1: path to a symlink
		Arg.expect "$1" && [ -L "$1" ] && [ -e "$1" ]
	}	# end File.islink


	File.path() {
		# return the full path to a single file in "files-common", looking
		# first into distro-xxx/files
		# return an empty string if nothing is found
		# $1 - relative path to search
		Arg.expect "$1" || return
		cmd readlink -e "$ENV_distro/files/$1" \
			|| cmd readlink -e "$ENV_files/$1" \
			|| return 1
	}	# end File.path


	File.place() {
		# copy a single file, from one of the "files-common" folders, to
		# the destination path in $2
		# $1 - file path relative to one of the "files-common" folders
		# $2 - destination full path
		Arg.expect "$1" "$2" || return
		local f=$( File.path $1 ) d="$2"
		[ -n "$f" ] && {
			[ -d "$d" ] && d="$d/$1"	# build destination
			File.recopy "$f" "$d"		# backup & copy
		}
	}	# end File.place


	File.paths() {
		# return the full path to all files matching $1
		# $1 - file path relative to one of the "files-common" folders
		Arg.expect "$1" || return
		local f=$( cmd find $ENV_distro/files -wholename "*$1" )
		[ -z "$f" ] && f=$( cmd find $ENV_files -wholename "*$1" )
		echo "$f"
	}	# end File.paths


	File.into() {
		# copy to the destination folder in $1, the files from ${@:2}
		# that can comes exclusively from one of the "files-common" folders
		Arg.expect "$1" "$2" || return

		# detect the real destination
		local a f d=$( cmd readlink -e $1 )
		[ -d "$d" ] || return

		for a in "${@:2}"; do				# iterating from 2nd arguments
			for f in $( File.paths "$a" )	# iterating files
			do
				File.recopy "$f" "$d/${f##*/}"
			done
		done
	}	# end File.into


	File.to() {
		# copy to the single destination folder in $1, one or more files in $@
		# that can comes exclusively from one of the "files-common" folders
		[ -d "$1" ] || return

		local ALT C A F D=$( cmd readlink -e $1 )
		shift

		# iterating containers
		for C in ${MyDISTRO} ${ENV_files}; do

			# iterating arguments
			for A in "${@}"; do

				# iterating files
				for F in $(find ${C} -wholename "*${A}"); do
					File.recopy "${F}" "${D}/$(basename ${F})"
					ALT=1
				done
			done
			[ -z "${ALT}" ] || break
		done
	}	# end File.to


	Cmd.usable() {
		# test argument $1 for: not empty & callable
		Arg.expect "$1" && command -v "$1" &> /dev/null
	}	# end Cmd.usable


	Pkg.installed() {
		# > /my/file  redirects stdout to /my/file
		# 1> /my/file redirects stdout to /my/file
		# 2> /my/file redirects stderr to /my/file
		# &> /my/file redirects stdout and stderr to /my/file

		# redirects stderr to the black hole
		[ -n "${1}" ] && dpkg -l "${1}" 2> /dev/null | grep -q ^ii
	}	# end Pkg.installed


	Pkg.installable() {
		# test argument $1 for: not empty & package installable
		Arg.expect "$1" && {
			Pkg.update	# update packages lists
			[ $( cmd apt-cache search "^$1$" | wc -l ) -gt 0 ] && return
		}
		return 1
	}	# end Pkg.installable


	Pkg.install() {
		Pkg.update	# update packages lists
		export DEBIAN_FRONTEND=noninteractive
		apt-get -qy \
			-o Dpkg::Options::="--force-confdef" \
			-o Dpkg::Options::="--force-confnew" \
			install "${@}"
	}	# end Pkg.install


	Pkg.update() {
		# the "apt-get update", to run before install any package
		cmd dpkg --configure -a	# in case apt is in a bad state

		# if an argument is given then forcing run apt-get
		[ -z "$1" ] || {
			Msg.info "Coerce the update of the package list for ${ENV_os}..."
			DOCLEANAPT=
		}

		[ -z "$DOCLEANAPT" ] && {
			DOCLEANAPT=1		# signal to do apt cleanup on exit
			cmd apt -qy update || {
				Msg.error "An errors occurred executing 'apt update'. Try again later..."
			}
		}
	}	# end Pkg.update


	Pkg.requires() {
		# check that the given packages are installed, if not
		# then it install all at once
		Arg.expect "$1" || return
		local p
		for p in "$@"
			do Pkg.installed "$p" || {
				Msg.info "Installing required packages: [ $@ ]"
				Pkg.install "$@"
				break
			}
		done
	}	# end Pkg.requires


	Pkg.purge() {
		# remove a single package via apt-get
		Arg.expect "$1" || return

		# it can be a command
		local c=$(command -v $1)

		# detect package from command
		c=${c:+$(dpkg -S "$c" 2> /dev/null)}
		c=${c%:*}	# remove optional arch (all char from the last ":")

		# do the real deletion
		Pkg.installed "$c" && {
			export DEBIAN_FRONTEND=noninteractive
			apt-get -qy purge --auto-remove "$c"
			Msg.info "Removing package '$c' (from '$1') completed!"
			return
		}

		Msg.warn "No package for '$1' is installed"
	}	# end Pkg.purge


	down_load() {
		# download via wget, returning an error on failure
		# $1 url
		# $2 destination name

		# we need exactly 2 arguments
		[ $# == 2 ] || {
			Msg.info "Missing arguments for downloading, exiting here..."
			exit
		}

		Pkg.requires wget
		cmd wget -nv --no-check-certificate "$1" -O "$2" || {
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
		local v=$(cmd php -v | grep -oP 'PHP [\d\.]+' | awk '{print $2}')
		[ "$1" = "major" ] && v=$(cmd awk -F. '{print $1}' <<< "$v")
		[ "$1" = "minor" ] && v=$(cmd awk -F. '{print $1"."$2}' <<< "$v")
		echo "$v"
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
			Msg.error "This app must be run as:" $(Dye.fg.white root)
		}
		local x t

		# test the availability of some required commands
		for x in awk apt-get cat cd cp debconf-set-selections dpkg \
			dpkg-reconfigure find grep head mkdir mv perl rm sed tr;
		do
			Cmd.usable "$x" || Msg.error "Missing command: $x"
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

		Cmd.usable 'nginx' && HTTP_SERVER='nginx'
	}	# end ENV.init


	OS.menu() {
		# display the main menu on screen
		local s o=""

		# One time actions
		s=""
		Cmd.usable "menu_ssh" && {
			s+="   . $(Dye.fg.orange ssh)         setup private key, shell, SSH on port $(Dye.fg.white $SSHD_PORT)\n"; }
		Cmd.usable "menu_deps" && {
			s+="   . $(Dye.fg.orange deps)        check dependencies, update the base system, setup firewall\n"; }
		[ -z "$s" ] || {
			o+=" [ . $(Dye.fg.white One time actions) ---------------------------------------------- (in recommended order) -- ]\n$s"; }

		# Standalone utilities
		s=""
		Cmd.usable "menu_upgrade" && {
			s+="   . $(Dye.fg.orange upgrade)     apt full upgrading of the system\n"; }
		Cmd.usable "menu_password" && {
			s+="   . $(Dye.fg.orange password)    print a random pw: \$1: length (6 to 32, 24), \$2: flag strong\n"; }
		Cmd.usable "menu_iotest" && {
			s+="   . $(Dye.fg.orange iotest)      perform the classic I/O test on the server\n"; }
		Cmd.usable "menu_resolv" && {
			s+="   . $(Dye.fg.orange resolv)      set $(Dye.fg.white /etc/resolv.conf) with public dns\n"; }
		Cmd.usable "menu_mykeys" && {
			s+="   . $(Dye.fg.orange mykeys)      set my authorized_keys, for me & backuppers\n"; }
		Cmd.usable "menu_tz" && {
			s+="   . $(Dye.fg.orange tz)          set the server timezone to $(Dye.fg.white $TIME_ZONE)\n"; }
		Cmd.usable "menu_motd" && {
			s+="   . $(Dye.fg.orange motd)        customize the dynamic Message of the Day (motd)\n"; }
		[ -z "$s" ] || {
			o+=" [ . $(Dye.fg.white Standalone utilities) ---------------------------------------- (in no particular order) -- ]\n$s"; }

		# Main applications
		s=""
		Cmd.usable "menu_mailserver" && {
			s+="   . $(Dye.fg.orange mailserver)  full mailserver with postfix, dovecot & aliases\n"; }
		Cmd.usable "menu_dbserver" && {
			s+="   . $(Dye.fg.orange dbserver)    the DB server MariaDB, root pw stored in $(Dye.fg.white ~/.my.cnf)\n"; }
		Cmd.usable "menu_webserver" && {
			s+="   . $(Dye.fg.orange webserver)   webserver apache2 or nginx, with php, selfsigned cert, adminer\n"; }
		[ -z "$s" ] || {
			o+=" [ . $(Dye.fg.white Main applications) --------------------------------------------- (in recommended order) -- ]\n$s"; }

		# Target system
		s=""
		Cmd.usable "menu_dns" && {
			s+="   . $(Dye.fg.orange dns)         bind9 DNS server with some related utilities\n"; }
		Cmd.usable "menu_assp1" && {
			s+="   . $(Dye.fg.orange assp1)       the AntiSpam SMTP Proxy version 1 (min 768ram 1core)\n"; }
		Cmd.usable "menu_ispconfig" && {
			s+="   . $(Dye.fg.orange ispconfig)   historical Control Panel, with support at $(Dye.fg.white howtoforge.com)\n"; }
		[ -z "$s" ] || {
			o+=" [ . $(Dye.fg.white Target system) ----------------------------------------------- (in no particular order) -- ]\n$s"; }

		# Others applications
		s=""
		Cmd.usable "menu_dumpdb" && {
			s+="   . $(Dye.fg.orange dumpdb)      to backup all databases, or the one given in $(Dye.fg.white \$1)\n"; }
		Cmd.usable "menu_roundcube" && {
			s+="   . $(Dye.fg.orange roundcube)   full featured imap web client\n"; }
		Cmd.usable "menu_nextcloud" && {
			s+="   . $(Dye.fg.orange nextcloud)   on-premises file share and collaboration platform\n"; }
		Cmd.usable "menu_espo" && {
			s+="   . $(Dye.fg.orange espo)        EspoCRM full featured CRM web application\n"; }
		Cmd.usable "menu_acme" && {
			s+="   . $(Dye.fg.orange acme)        shell script for Let's Encrypt free SSL certificates\n"; }
		[ -z "$s" ] || {
			o+=" [ . $(Dye.fg.white Others applications) ----------------------------------- (depends on main applications) -- ]\n$s"; }

		echo -e " $(Date.fmt +'%F %T %z') :: $(Dye.fg.orange $ENV_os $ENV_arch) :: ${ENV_dir}\n$o" \
			"[ ------------------------------------------------------------------------------------------- ]"
	}	# end OS.menu
