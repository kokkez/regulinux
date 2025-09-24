# ==============================================================================
# companion library of the script for install Linux OSes
# ==============================================================================

#	DEFAULT VARIABLES
#	----------------------------------------------------------------------------
	ENV_product='unknown'				# linux distribution
	ENV_version='unknown'				# version of the distribution
	ENV_release='unknown'				# linux <product>-<version>
	ENV_codename='unknown'				# codename of the distribution
	ENV_arch='unknown'					# kernel architecture

	TARGET='unknown'
	TIME_ZONE='Europe/Rome'
	SSHD_PORT='64128'
	FW_allowed='ssh'
	DNS_v4='1.1.1.1 9.9.9.10 1.0.0.1 149.112.112.10'	# cf q9 cf q9
	DNS_v6='2606:4700:4700::1111 2620:fe::fe'			# cf q9

	HOST_NICK="$(command hostname -s)"
	HOST_FQDN="$(command hostname -f)"
	ROOT_MAIL="k-$HOST_NICK@rete.us"
	LENC_MAIL="k-letsencrypt@rete.us"	# letsencrypt account email

	MAIL_NAME="$HOST_FQDN"
	DB_rootpw=""
	ASSP_ADMINPW="zeroSpam4me"

	CERT_C='IT'
	CERT_ST='Reggio Emilia'
	CERT_L='Bagnolo in Piano'
	CERT_O='italmedia.net'
	CERT_OU='internet-server'
	CERT_CN="$HOST_FQDN"
	CERT_E="$ROOT_MAIL"

	HTTP_SERVER='apache2'  # apache2 or nginx
	ISP3_MULTISERVER='n'   # "n" or "y"
	ISP3_MASTERHOST=''     # fqdn of the master ispconfig multiserver db, or empty
	ISP3_MASTERUSER='root' # username of the master db, usually root
	ISP3_MASTERPASS=''     # password of the master db, if empty will be asked

	# -- bash colors -----------------------------------------------------------
	Dye.as() {
		# output painted text
		# $1 num : type (default 0, dark)
		# $2 num : color (default 37, gray)
		# $3 text: message to colorize (replacing default with starting color)
		local m t="${1:-0}" c="${2:-37}"
		m=$(sed "s|\[0m|[$t;${c}m|g" <<<"${*:3}")
		printf '\e[%s;%sm%s\e[0m\n' "$t" "$c" "$m"
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
		# helper function for verifying arguments for not empty
		# expects: variable number of arguments ( $1 [, $2 [, $3 ... ]] )
		local i
		for (( i = 1; i <= $#; i++ )); do
			[ -z "${!i}" ] \
				&& Msg.warn "Missing argument #$i to ${FUNCNAME[1]}()" \
				&& return 1
		done
		return 0
	};


	Cmd.usable() {
		# test every argument for: not empty & callable
		Arg.expect "$1" || return 1
		local c
		for c; do
			command -v "$c" &> /dev/null || {
				#Msg.warn "Required command not found: $c"
				return 1
			}
		done
		return 0
	}	# end Cmd.usable


	cmd() {
		# try to run the real command, not an aliased version
		# on missing command, or error, it return silently
		Arg.expect "$1" || return
		local c="$(type -P "$1")"
		shift && [ -n "$c" ] && "$c" "$@"
	}	# end cmd


	Date.fmt() {
		# return a formatted date/time, providing a custom default
		#echo -e $(date "${@-+'%F %T'}")
		date "${@:-'+%F %T'}"
	}	# end Date.fmt


	Dir.delete() {
		# if directory exists then delete it
		# $1: path to folder
		# $2: optional message
		Arg.expect "$1" && [ -d "$1" ] && {
			[ -n "$2" ] && echo -e "${@:2}"
			rm -rf "$1"
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
		Arg.expect "$1" && [ -e "$1.backup" ] && return
		# if original is not empty, copy it to backup
		[ -s "$1" ] && cp "$1" "$1.backup"
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
		# return the full path to a single file into one of the "files" folders,
		# looking first into distro-xx/files
		# return an empty string if nothing is found
		# $1 - relative path to search
		Arg.expect "$1" || return
		readlink -e "$ENV_dir/distro-$ENV_codename/files/$1" \
			|| readlink -e "$ENV_dir/files/$1" \
			|| return 1
	}	# end File.path


	File.place() {
		# copy a single file, from one of the "files" folders, to
		# the destination path in $2, with precedence to "distro-xx/files"
		# $1 - file path relative to one of the "files" folders
		# $2 - destination full path
		Arg.expect "$1" "$2" || return
		local f=$( File.path "$1" ) d="$2"
		[ -n "$f" ] && {
			[ -d "$d" ] && d="$d/$1"	# build destination
			File.recopy "$f" "$d"		# backup & copy
		}
	}	# end File.place


	File.paths() {
		# return the full path to all files matching $1
		# $1 - file path relative to one of the "files" folders
		Arg.expect "$1" || return
		local f=$(find $ENV_dir/distro-$ENV_codename/files -wholename "*$1")
		[ -z "$f" ] && f=$(find $ENV_dir/files -wholename "*$1")
		echo "$f"
	}	# end File.paths


	File.into() {
		# copy into the destination folder in $1, the files from ${@:2}
		# that can comes exclusively from one of the "files" folders,
		# with precedence to "distro-xx/files"
		# $1     - destination folder path
		# ${@:2} - file path relative to one of the "files" folders
		Arg.expect "$1" "$2" || return

		# detect the real destination
		local a f d=$(readlink -e "$1")
		[ -d "$d" ] || return				# abort if dest. is not a folder

		for a in "${@:2}"; do				# iterating from 2nd arguments
			for f in $(File.paths "$a")		# iterating files
			do
				File.recopy "$f" "$d/${f##*/}"
			done
		done
	}	# end File.into


	Pkg.update() {
		# the "apt-get update", to run before install any package
		dpkg --configure -a		# in case apt is in a bad state

		# if an argument is given then forcing run apt-get
		[ -z "$1" ] || {
			Msg.info "Coerce the update of the package list for ${ENV_os}..."
			DOCLEANAPT=
		}

		[ -z "$DOCLEANAPT" ] && {
			DOCLEANAPT=1		# signal to do apt cleanup on exit
			apt -qy update || {
				Msg.error "An errors occurred executing 'apt update'. Try again later..."
			}
		}
	}	# end Pkg.update


	Pkg.install() {
		Pkg.update	# update packages lists
		export DEBIAN_FRONTEND=noninteractive
		apt-get -qy \
			-o Dpkg::Options::="--force-confdef" \
			-o Dpkg::Options::="--force-confnew" \
			install "${@}"
	}	# end Pkg.install


	Pkg.installed() {
		# return 0 if single package is installed, 1 otherwise
		# $1 = single package to check
		[ -n "$1" ] && dpkg -s "$1" &>/dev/null
	}	# end Pkg.installed


	Pkg.requires() {
		# check that the given packages are installed, if not
		# then it install all at once
		Arg.expect "$1" || return
		local p
		for p in "$@"; do
			Pkg.installed "$p" || {
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


	File.download() {
		# download via wget, returning an error on failure
		# $1 url
		# $2 destination name
		Arg.expect "$1" "$2" || exit

		Pkg.requires wget ca-certificates
		wget -nv --no-check-certificate "$1" -O "$2" || {
			Msg.info "Download failed ( $2 ), exiting here..."
			exit
		}
	}	# end File.download


	Port.audit() {
		# set port in $1 to be strictly numeric & in a known range
		# $1 - port number, optional, defaults to 22 (ssh)
		local t l p=$(awk '{print int($1)}' <<< ${1:-22})
		(( p == 22 )) || {
			# limit min & max range
			p=$(( p > 65534 ? 65535 : p < 1025 ? 1024 : p ))
			# exclude net.ipv4.ip_local_port_range (32768-60999)
			#t=$(cmd sysctl -e -n net.ipv4.ip_local_port_range )
			#l=$(awk '{print int($1)}' <<< $t)
			#t=$(awk '{print int($2)}' <<< $t)
			#p=$(( p < l ? p : p > t ? p : 64128 ))
		}
		echo $p
	}	# end Port.audit


	Version.numeric() {
		# return the cleaned numeric version of a program
		# $1 - given a version like 7a.3b.112f -> 7.3.112
		Arg.expect "$1" || return
		awk -F. '{ printf("%d.%d.%d\n",$1,$2,$3) }' <<< "$@"
	}	# end Version.numeric


	Version.php() {
		# return the dotted number of the cli version of PHP
		# $1 - word to specify the wanted result like this: given 7.4.33
		#  major -> 7
		#  minor -> 7.4
		#  otherwise -> 7.4.33
		local v=$(cmd php -v | awk 'NR==1 {print $2}')
		case "$1" in
			ma*) v=${v%%.*} ;;	# major
			mi*) v=${v%.*} ;;	# major.minor
		esac
		echo "$v"
	}	# end Version.php


	ISPConfig.installed() {
		# exits with 0 (success) if ispconfig is installed
		# no arguments expected
		[ -s '/usr/local/ispconfig/server/lib/config.inc.php' ]
	}	# end ISPConfig.installed


	Element.in() {
		# check that $1 is an argument of this Fn, starting from $2
		# no arguments can contains spaces
		# $1 - element to check
		# $2+ - arguments separated by space, our array of elements
		local e w="$1"
		shift
		for e; do [ "$e" = "$w" ] && return 0; done
		# default return falsy
		return 1
	};	# end of Element.in


	Partition.space() {
		# return the free space of the current partition in kb
		# $1 - argument to check
		local k=${1:-free}
		declare -A w
		w=([filesystem]=1 [size]=2 [used]=3 [free]=4 [percent]=5 [mount]=6)
		k=${w[${k,,}]}
		[ -z "${k}" ] || (( k < 1 )) && k=4		# default index
		echo $(df -Pk . | awk "NR==2 {print \$$k}")
	};	# end of Partition.space


	Unit.convert() {
		# convert suffixed units to kilobytes
		# $1 - value to convert
		local n u z=$1
		n=${z%[A-Za-z]*}					# number
		u=${z//[0-9]}						# unit

		case "$u" in
			G|g) echo "$((n * 1048576))";;	# from giga (1 GB = 1024 MB)
			M|m) echo "$((n * 1024))";;		# from mega
			K|k) echo "$n";;				# from kilo
			*)   echo "0";;					# unknown or missing
		esac;
	};	# end of Unit.convert


	Config.set() {
		# save a configuration value into ./settings.conf
		# $1 config name
		# $2 config value
		Arg.expect "$1" || exit

		local k v p="$ENV_dir/settings.conf"
		k="$1"								# config name
		v="$2"								# config value

		# save or append config line
		if grep -q "^$k=" "$p"; then
			sed -ri "$p" -e "s|^($k=).+|$k=\"$v\"|"
		else
			echo "$k=\"$v\"" >> "$p"
		fi;
		source "$p"							# reload configs
	};	# end of Config.set


#	MAIN MENU
#	----------------------------------------------------------------------------

	ENV.clean() {
		# do apt cleanup if $1 is not empty
		[ -n "$DOCLEANAPT" ] && {
			unset DOCLEANAPT
			apt-get -qy purge				# remove packages and config files
			apt-get -qy autoremove			# remove unused packages automatically
			apt-get -qy autoclean			# erase old downloaded archive files
			apt-get -qy clean				# erase downloaded archive files
			rm -rf /var/lib/apt/lists/*		# delete the entire cache
		}
	}	# end ENV.clean


	ENV.config() {
		# read configurations for the current installation
		# the file will be created if missing
		local k p="$ENV_dir/settings.conf"

		# creating file with the default values as defined in ./lib.sh
		[ -s "$p" ] || {
			for k in TARGET TIME_ZONE SSHD_PORT FW_allowed DNS_v4 DNS_v6 \
				HOST_NICK HOST_FQDN ROOT_MAIL LENC_MAIL MAIL_NAME DB_rootpw ASSP_ADMINPW \
				CERT_C CERT_ST CERT_L CERT_O CERT_OU CERT_CN CERT_E HTTP_SERVER
			do echo "$k=\"${!k}\""
			done > "$p"
			Msg.info "Creation of config file $(Dye.fg.white $p) completed..."
		}
		source "$p"	# reload configs
	}	# end ENV.config


	ENV.init() {
		# initializes the environment
		# no arguments expected

		# user must be root (id == 0)
		(( $(id -u) )) && {
			Msg.error "This is Regulinux and must be run as:" $(Dye.fg.white root)
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
		elif [ -s /etc/issue.net ]; then		# file exists & ! empty
			t=$(head -1 /etc/issue.net)
			t=${t,,}							# line lowercased
			ENV_product=${t%% *}				# keep text before 1st space
			ENV_version=$(grep -oP '[\d.]+' <<< "$t" | head -1)
		fi;

		# setup some environment variables
		ENV_release="${ENV_product}-$ENV_version"
		ENV_arch=$(uname -m)

		case $ENV_release in
		#	"debian-7")     ENV_codename="wheezy"   ;;
			"debian-8")     ENV_codename="jessie"   ;;
			"debian-9")     ENV_codename="stretch"  ;;
			"debian-10")    ENV_codename="buster"   ;; # 2020-05
			"debian-11")    ENV_codename="bullseye" ;; # 2022-08
			"debian-12")    ENV_codename="bookworm" ;; # 2024-07
			"debian-13")    ENV_codename="trixie"   ;; # 2025-09
#			"ubuntu-16.04") ENV_codename="xenial"   ;;
			"ubuntu-18.04") ENV_codename="bionic"   ;; # 2020-04
			"ubuntu-20.04") ENV_codename="focal"    ;; # 2021-01
			"ubuntu-22.04") ENV_codename="jammy"    ;; # 2025-07
		esac;

		# control that release isnt unknown
		[ "$ENV_codename" = "unknown" ] && {
			Msg.error "This distribution is not supported: ${ENV_release^}"
		}

		# append to parent folder name the discovered infos
		t=${ENV_dir%/*}/regulinux-$ENV_release-$ENV_codename-$ENV_arch
		[ -d "$t" ] || {
			mv ~/regulinux* "$t"
			ENV_dir="$t"
		}

		# setup ENV_os capitalizing the first letter
		ENV_os="${ENV_release^} ($ENV_codename)"

		# removing unneeded distros
		for x in $ENV_dir/distro-*
			do [ "$x" = "$ENV_dir/distro-$ENV_codename" ] || rm -rf "$x"
		done

		# sourcing all common functions
		for x in $ENV_dir/functions/fn_*
			do . "$x"
		done

		# sourcing all distro's functions, that can redefine the previous
		for x in $ENV_dir/distro-$ENV_codename/fn_*
			do . "$x"
		done

		Cmd.usable 'nginx' && HTTP_SERVER='nginx'
		ENV.config	# load configurations from file
	}	# end ENV.init


	Text.pad() {
		# returns a padding string
		# $1 = desired final length
		# $2 = text to repeat (default: space)
		# $3 = optional string, its length is subtracted from $1
		local t=${2:- } o=${3:-}
		printf '%*s' $(( $1 - ${#o} )) '' | tr ' ' "$t"
	}	# end Text.pad


	Meta.get() {
		# extract metadata value for given key from a function body
		# $1 = metadata key (e.g. __section, __summary, __exclude)
		# $2 = function body string to search in
		# returns the string inside quotes following key=, or empty if not found
		[[ $2 =~ $1=[\'\"]([^\'\"]*)[\'\"] ]] && echo "${BASH_REMATCH[1]}" || echo ""
	}	# end Meta.get


	OS.menu() {
		# it builds the full menu finding conventioned functions
		local sec=(
			"One time actions|(in recommended order)"
			"Standalone utilities|(in no particular order)"
			"Main applications|(in recommended order)"
			"Target system|(in no particular order)"
			"Others applications|(depends on main applications)"
		)
		local -A out
		local f b g d
		for f in $(compgen -A function Menu.); do
			b=$(declare -f "$f")
			g=$(Meta.get __exclude "$b")	# check __exclude (interpreted outside)
			[[ -n $g ]] && eval "$g" && continue
			g=$(Meta.get __section "$b")	# check __section, skip if empty
			[[ -z $g ]] && continue
			eval "d=\"$(Meta.get __summary "$b")\""	# expanding vars & $()
			b="${f#*.}"
			out[$g]+=$(printf ' : %s %s %s' "$(Dye.fg.orange $b)" "$(Text.pad 12 ' ' "$b")" "$d")
			out[$g]+=$'\n'
		done

		# output header
		b="$ENV_os $ENV_arch"
		g=$(systemd-detect-virt)
		printf '+%s+\n %-85s%26s\n %-71s%(%F %T %z)T\n' \
			"$(Text.pad 96 :)" \
			"$(Dye.fg.orange $b)" "$(hostnamectl | awk '/Cha/ {print $2}') ( ${g:-dedi} )" \
			"$ENV_dir" "-1"

		# output sections
		for g in "${sec[@]}"; do
			b=${g%%|*}
			[[ -z ${out[$b]} ]] && continue
			g=${g#*|}
			printf '+- %s %s %s -+\n' \
				"$(Dye.fg.white $b)" "$(Text.pad 90 - "$b$g")" "$g"
			printf '%s' "${out[$b]}"
		done

		# output footer
		printf '+%s+\n' "$(Text.pad 96 :)"
	}	# end OS.menu
