# ------------------------------------------------------------------------------
# custom functions specific to ubuntu 20.04 focal
# ------------------------------------------------------------------------------

Menu.upgrade() {
	Msg.info "Upgrading system packages for ${ENV_os}..."
	Pkg.update	# update packages lists

	# do the apt upgrade
	export DEBIAN_FRONTEND=noninteractive
	cmd apt -qy full-upgrade
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


sslcert_symlink() {
	# create the symlink pointing to a real file
	# $1 - path to the file to convert to symlink
	# $2 - path to the target file
	File.islink "$1" || {
		[ -s "$1" ] && {
			mv -f "$1" "${1}.bak"
			[ "${2:0:1}" = "/" ] || cd $(cmd dirname "$1")
			[ -s "$2" ] && ln -nfs "$2" "$1"
		}
	}
}	# end sslcert_symlink


sslcert_paths() {
	# adjust paths to points to these certificates
	# $1 - full path to the key file
	# $2 - full path to the certificate file
	Arg.expect "$1" "$2" || return

	# default certificate paths
	sslcert_symlink '/etc/ssl/private/ssl-cert-snakeoil.key' "$1"
	sslcert_symlink '/etc/ssl/certs/ssl-cert-snakeoil.pem' "$2"

	# postfix certificate paths
	sslcert_symlink '/etc/postfix/smtpd.key' "$1"
	sslcert_symlink '/etc/postfix/smtpd.cert' "$2"

	# ispconfig certificate paths
	sslcert_symlink '/usr/local/ispconfig/interface/ssl/ispserver.key' "$1"
	sslcert_symlink '/usr/local/ispconfig/interface/ssl/ispserver.crt' "$2"

	# adjust default-ssl symlink for apache
	[ -s /etc/apache2/sites-available/default-ssl.conf ] && {
		cd /etc/apache2/sites-enabled
		File.islink '0000-default-ssl.conf' || {
			ln -s ../sites-available/default-ssl.conf '0000-default-ssl.conf'
			rm -rf default-ssl*
		}
		# enable related modules, then restart apache2
		a2enmod rewrite headers ssl
		cmd systemctl restart apache2
	}

	# restart nginx webserver if installed
	[ "$HTTP_SERVER" = "nginx" ] && cmd systemctl restart nginx

	Msg.info "Symlinks for the given SSL Certificate completed!"
}	# end sslcert_paths


Install.firewall() {
	# setup firewall using firewalld via nftables
	# $1 - ssh port number, optional

	# add required software & purge unwanted
	Pkg.requires firewalld
	Pkg.purge "ufw"

#	Pkg.installed "iptables" || {
#		Msg.error "Seems that iptables was missing"
#	}

	SSHD_PORT=$( Port.audit ${1:-$SSHD_PORT} )	# strictly numeric port

	# make rules persistent, so they can load at every boot
#	local p=/etc/network/if-pre-up.d
#	rm -rf "$p/iptables"
#	File.into "$p" ssh/iptables
#	chmod +x "$p/iptables"						# make it executable

#	Fw.allow 'ssh'								# allow SSH by default

	cmd firewall-cmd --add-port=$p/tcp --permanent	# activate ssh
	cmd firewall-cmd --reload
}	# end Install.firewall
