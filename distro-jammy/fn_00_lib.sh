# ------------------------------------------------------------------------------
# custom functions specific to ubuntu 22.04 jammy
# ------------------------------------------------------------------------------

Arrange.unhang() {
	# mitigating ssh hang on reboot on systemd capables OSes
	# no more needed on ubuntu jammy
	Msg.debug "Arrange.unhang(): skipped (not needed on $ENV_os $ENV_arch)"
}	# end Arrange.unhang


Install.syslogd() {
	# no more needed, rsyslog is modern and default
	Msg.debug "Install.syslogd: skipped (rsyslog is modern and default)"
}	# end Install.syslogd


Menu.upgrade() {
	# metadata for OS.menu entries
	__section='Standalone utilities'
	__summary="perform a full system upgrade via apt"

	Msg.info "Upgrading system packages for ${ENV_os}..."
	Pkg.update	# update packages lists

	# do the apt upgrade
	export DEBIAN_FRONTEND=noninteractive
	apt -qy full-upgrade

	# disable ubuntu-advantage-tools apt hook if present
	local p='/etc/apt/apt.conf.d/20apt-esm-hook.conf'
	# skip if already disabled
	[ -e "$p.disabled" ] || {
		[ -e "$p" ] && {
			mv "$p" "$p.disabled"
			Msg.info "Disabling apt hook: ${p##*/}, completed!"
		}
	}

	# remove every file in /etc/update-motd.d
	shopt -s nullglob
	p=(/etc/update-motd.d/*)
	shopt -u nullglob
	if (( ${#p[@]} )); then
		rm -f "${p[@]}"
		Msg.info "Removed ${#p[@]} files in /etc/update-motd.d/"
	fi
}	# end Menu.upgrade


Repo.php() {
	# add external repository for updated php
	local p='/etc/apt/sources.list.d/php.list'
	[ -s "$p" ] && return

	# add required software & the repo key
	Pkg.requires gnupg
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
	cat > "$p" <<EOF
# Ondrej Sury Repo for PHP 7.x [ https://www.patreon.com/oerdnj ]
deb http://ppa.launchpad.net/ondrej/php/ubuntu $ENV_codename main
# deb-src http://ppa.launchpad.net/ondrej/php/ubuntu $ENV_codename main
EOF
	# forcing apt update
	Pkg.update 'coerce'
}	# end Repo.php


Mnu.pad() {
	# return a string to be used as padding
	# $1 wanted total length
	# $2 char to use to pad
	# $3 string to count the length
	local p d=$(( $1 - ${#3} ))
	while (( d-- )); do p+=$2; done
	echo "$p"
}	# end Mnu.pad


Mnu.meta() {
	# extract metadata value for given key from a function body
	# $1 metadata key (e.g. __section, __summary, __exclude)
	# $2 function body string to search in
	# returns the string inside quotes following key=, or empty if not found
	[[ $2 =~ $1=[\'\"]([^\'\"]*)[\'\"] ]] && echo "${BASH_REMATCH[1]}" || echo ""
}	# end Mnu.meta


Menu.build() {
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
		g=$(Mnu.meta __exclude "$b")	# check __exclude (interpreted outside)
		[[ -n $g ]] && eval "$g" && continue
		g=$(Mnu.meta __section "$b")	# check __section, skip if empty
		[[ -z $g ]] && continue
		d=$(Mnu.meta __summary "$b")	# get __summary, expanding variables
		[[ -n $d ]] && d=$(eval "echo \"$d\"")
		b="${f#*.}"
		out[$g]+=$(printf ' : %s %s %s' "$(Dye.fg.orange $b)" "$(Mnu.pad 12 ' ' "$b")" "$d")
		out[$g]+=$'\n'
	done

	# output header
	b="$ENV_os $ENV_arch"
	d=$(Date.fmt +'%F %T %z')
	printf '+%s+\n %s%s%s\n %s\n' \
		"$(Mnu.pad 96 :)" \
		"$(Dye.fg.orange "$b")" "$(Mnu.pad 96 ' ' "$b$d")" "$d" \
		"$ENV_dir"

	# output sections
	for g in "${sec[@]}"; do
		b=${g%%|*}
		[[ -z ${out[$b]} ]] && continue
		g=${g#*|}
		printf '+- %s %s %s -+\n' \
			"$(Dye.fg.white $b)" "$(Mnu.pad 90 - "$b$g")" "$g"
		printf '%s' "${out[$b]}"
	done

	# output footer
	printf '+%s+\n' "$(Mnu.pad 96 : "")"
}	# end Menu.build


Mnu.olditems() {
	cat <<- EOF
    root        setup private key, sources.list, shell, SSH on port $(Dye.fg.white $SSHD_PORT)  One time actions
    deps        run prepare, check dependencies, update the base system, setup firewall         One time actions
    reinstall   reinstall OS on VM (not containers) default $(Dye.fg.white Debian 12)           One time actions

    upgrade     perform a full system upgrade via apt                                           Standalone utilities
    addswap     add a file to be used as SWAP memory, default $(Dye.fg.white 512M)              Standalone utilities
    password    print a random pw: \$1: length (6 to 32, 24), \$2: flag strong                  Standalone utilities
    mnemonic    mnemonic password of 2 words separated by a dash                                Standalone utilities
    bench       basic benchmark to get OS info                                                  Standalone utilities
    iotest      perform the classic I/O test on the server                                      Standalone utilities
    resolv      set $(Dye.fg.white /etc/resolv.conf) with public dns                            Standalone utilities
    mykeys      set my authorized_keys, for me & backuppers                                     Standalone utilities
    tz          set the server timezone to $(Dye.fg.white $TIME_ZONE)                           Standalone utilities
    inet        retrieve network-related information from the system                            Standalone utilities

    mailserver  full mailserver with postfix, dovecot & aliases                                 Main applications
    dbserver    the DB server MariaDB, root pw stored in $(Dye.fg.white '~/.my.cnf')            Main applications
    webserver   webserver apache2 or nginx, with php, selfsigned cert, adminer                  Main applications

    dns         bind9 DNS server with some related utilities                                    Target system
    assp1       the AntiSpam SMTP Proxy version 1 (min 768ram 1core)                            Target system
    isp3ai      historical Control Panel, with support at $(Dye.fg.white howtoforge.com)        Target system
    ispconfig   historical Control Panel, with support at $(Dye.fg.white howtoforge.com)        Target system
    fms         the full $(Dye.fg.white FileMaker Server), trial version                        Target system

    firewall    set up the firewall using iptables (v4 and v6)                                  Others applications
    dumpdb      to backup all databases, or the one given in $(Dye.fg.white \$1)                Others applications
    roundcube   full featured imap web client                                                   Others applications
    nextcloud   on-premises file share and collaboration platform                               Others applications
    espo        EspoCRM full featured CRM web application                                       Others applications
    acme        shell script for Let's Encrypt free SSL certificates                            Others applications
	EOF
}	# end Mnu.olditems
