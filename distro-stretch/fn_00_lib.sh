# ------------------------------------------------------------------------------
# customized functions for debian 9 stretch
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
		pkg_require apt-transport-https lsb-release ca-certificates
		down_load https://packages.sury.org/php/apt.gpg /etc/apt/trusted.gpg.d/php.gpg
		cat > ${P} <<EOF
# https://www.patreon.com/oerdnj
deb http://packages.sury.org/php stretch main
#deb-src http://packages.sury.org/php stretch main
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
