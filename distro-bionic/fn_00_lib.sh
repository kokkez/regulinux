# ------------------------------------------------------------------------------
# customized functions for ubuntu 18.04 bionic
# ------------------------------------------------------------------------------

help_menu() {
	# display the main menu on screen
	echo -e " $(date '+%Y-%m-%d %T %z') :: ${cORNG}${OS} (${DISTRO}) ${ARCH}${cNULL} :: ${MyDir}
 [ . ${cWITELITE}Basic menu options${cNULL} ---------------------------- (in recommended order) -- ]
   . ${cORNG}ssh${cNULL}         setup private key, shell, SSH on port ${cWITELITE}${SSHD_PORT}${cNULL}
   . ${cORNG}deps${cNULL}        check dependencies, update the base system, setup firewall
 [ . ${cWITELITE}Standalone utilities${cNULL} ------------------------ (in no particular order) -- ]
   . ${cORNG}upgrade${cNULL}     apt full upgrading of the system
   . ${cORNG}password${cNULL}    print a random pw: \$1: length (6 to 32, 24), \$2: flag strong
   . ${cORNG}iotest${cNULL}      perform the classic I/O test on the VPS
 [ . ${cWITELITE}Main applications${cNULL} ----------------------------- (in recommended order) -- ]
   . ${cORNG}mailserver${cNULL}  full mailserver with postfix, dovecot & aliases
   . ${cORNG}dbserver${cNULL}    the DB server MariaDB, root pw in ${cWITELITE}~/.my.cnf${cNULL}
   . ${cORNG}webserver${cNULL}   webserver apache2 or nginx, with php, selfsigned cert, adminer
 [ . ${cWITELITE}Target system${cNULL} ------------------------------- (in no particular order) -- ]
   . ${cORNG}dns${cNULL}         bind9 DNS server with some related utilities
   . ${cORNG}ispconfig${cNULL}   the magic Control Panel of the nice guys at howtoforge.com
 [ . ${cWITELITE}Others applications${cNULL} ------------------- (depends on main applications) -- ]
   . ${cORNG}roundcube${cNULL}   full featured imap web client
   . ${cORNG}acme${cNULL}        shell script for Let's Encrypt free certificate client
   . ${cORNG}nextcloud${cNULL}   on-premises file share and collaboration platform
   . ${cORNG}dumpdb${cNULL}      perform the backup of all databases, or the one given in \$1
 -------------------------------------------------------------------------------"
}	# end help_menu

# ------------------------------------------------------------------------------

menu_upgrade() {
	msg_info "Upgrading system packages for ${OS} (${DISTRO})..."
	pkg_update	# update packages lists

	# do the apt upgrade
	export DEBIAN_FRONTEND=noninteractive
	cmd apt -qy full-upgrade
}	# end menu_upgrade

# ------------------------------------------------------------------------------

add_php_repository() {
	local P="/etc/apt/sources.list.d/php.list"

	# add external repository for updated php
	[ -s ${P} ] || {
		pkg_require gnupg
		apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
		cat > ${P} <<EOF
# Ondrej Sury Repo for PHP 7.x [ https://www.patreon.com/oerdnj ]
deb http://ppa.launchpad.net/ondrej/php/ubuntu bionic main
# deb-src http://ppa.launchpad.net/ondrej/php/ubuntu bionic main
EOF
		# forcing apt update
		pkg_update true
	}
}	# end add_php_repository

# ------------------------------------------------------------------------------

sslcert_symlink() {
	# create the symlink pointing to a real file
	# $1 - path to the file to convert to symlink
	# $2 - path to the target file
	is_symlink "${1}" || {
		[ -s "${1}" ] && {
		mv -f "${1}" "${1}.bak"
		[ "${2:0:1}" = "/" ] || cd $(cmd dirname "${1}")
			[ -s "${2}" ] && ln -nfs "${2}" "${1}"
		}
	}
}	# end sslcert_symlink

# ------------------------------------------------------------------------------

sslcert_paths() {
	# adjust paths to points to these certificates
	# $1 - full path to the key file
	# $2 - full path to the certificate file
	[ -s ${1} ] && [ -s ${2} ] || return

	# default certificate paths
	sslcert_symlink "/etc/ssl/private/ssl-cert-snakeoil.key" "${1}"
	sslcert_symlink "/etc/ssl/certs/ssl-cert-snakeoil.pem" "${2}"

	# postfix certificate paths
	sslcert_symlink "/etc/postfix/smtpd.key" "${1}"
	sslcert_symlink "/etc/postfix/smtpd.cert" "${2}"

	# ispconfig certificate paths
	sslcert_symlink "/usr/local/ispconfig/interface/ssl/ispserver.key" "${1}"
	sslcert_symlink "/usr/local/ispconfig/interface/ssl/ispserver.crt" "${2}"

	# adjust default-ssl symlink for apache
	[ -s /etc/apache2/sites-available/default-ssl.conf ] && {
		cd /etc/apache2/sites-enabled
		is_symlink '0000-default-ssl.conf' || {
			ln -s ../sites-available/default-ssl.conf '0000-default-ssl.conf'
			rm -rf default-ssl*
		}
		# enable related modules, then restart apache2
		a2enmod rewrite headers ssl
		cmd systemctl restart apache2
	}

	# restart nginx webserver if installed
	[ "${HTTP_SERVER}" = "nginx" ] && cmd systemctl restart nginx

	msg_info "Symlink for the given SSL Certificate completed!"
}	# end sslcert_paths
