# ------------------------------------------------------------------------------
# customized functions for ubuntu bionic
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
	# append external repository to sources.list for updated php
	cd /etc/apt
	grep -q 'Ondrej Sury' sources.list || {
		pkg_require gnupg
		apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
		cat >> sources.list <<EOF

# Ondrej Sury Repo for PHP 7.x [ https://www.patreon.com/oerdnj ]
deb http://ppa.launchpad.net/ondrej/php/ubuntu bionic main
# deb-src http://ppa.launchpad.net/ondrej/php/ubuntu bionic main
EOF
	}

	# forcing apt update
	pkg_update true
}	# end add_php_repository

# ------------------------------------------------------------------------------

sslcert_symlink() {
	# create the symlink pointing to a real file
	# $1 - file path to convert to symlink
	# $2 - path to the real file
	[ -s ${1} ] && is_symlink ${1} || {
		mv -f ${1} ${1}.bak
		[ "${2:0:1}" = "/" ] || cd $(cmd dirname ${1})
		ln -nfs ${2} ${1}
	}
}	# end sslcert_symlink

# ------------------------------------------------------------------------------

sslcert_paths() {
	# adjust paths to points to these certificates
	# $1 - full path to the key file
	# $2 - full path to the certificate file

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

	# ispconfig certificate paths
	[ "${HTTP_SERVER}" = "nginx" ] && cmd systemctl restart nginx
}	# end sslcert_paths
