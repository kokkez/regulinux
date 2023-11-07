# ------------------------------------------------------------------------------
# custom functions specific to debian 11 bullseye
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

	# add external repository for updated php
	Pkg.requires apt-transport-https lsb-release ca-certificates
	File.download https://packages.sury.org/php/apt.gpg /etc/apt/trusted.gpg.d/php.gpg
	cat > "$p" <<- EOF
		# https://www.patreon.com/oerdnj
		deb http://packages.sury.org/php $ENV_codename main
		#deb-src http://packages.sury.org/php $ENV_codename main
		EOF
	# forcing apt update
	Pkg.update 'coerce'
}	# end Repo.php


Arrange.sshd() {
	# configure SSH server parameters
	# $1: ssh port number, optional
	SSHD_PORT=$( Port.audit ${1:-$SSHD_PORT} )
	cmd sed -ri /etc/ssh/sshd_config \
		-e "s|^#?(Port)\s.*|\1 $SSHD_PORT|" \
		-e 's|^#?(PasswordAuthentication)\s.*|\1 no|' \
		-e 's|^#?(PermitRootLogin)\s.*|\1 without-password|' \
		-e 's|^#?(RSAAuthentication)\s.*|\1 yes|' \
		-e 's|^#?(PubkeyAuthentication)\s.*|\1 yes|'
	cmd systemctl restart ssh
	Config.set "SSHD_PORT" "$SSHD_PORT"
	Msg.info "SSH server is now listening on port: $SSHD_PORT"
}	# end Arrange.sshd


# legacy version of the iptables commands, needed by firewall
Fw.ip4() {
	cmd iptables-legacy "$@"
}
Fw.ip6() {
	cmd ip6tables-legacy "$@"
}
Fw.ip4save() {
	cmd iptables-legacy-save "$@"
}
Fw.ip6save() {
	cmd ip6tables-legacy-save "$@"
}


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


Install.firewalld() {
	# setup firewall using firewalld via nftables
	# https://blog.myhro.info/2021/12/configuring-firewalld-on-debian-bullseye
	# $1 - ssh port number, optional

	# add required software & purge unwanted
	Pkg.requires firewalld

	SSHD_PORT=$( Port.audit ${1:-$SSHD_PORT} )	# strictly numeric port

	# make our ssh persistent, so that can be loaded at every boot
	cmd firewall-cmd -q --permanent --add-port=$SSHD_PORT/tcp

	# set packets to be silently dropped, instead of actively rejected
	cmd firewall-cmd -q --permanent --set-target DROP

	# remove default ports, permanently
	cmd firewall-cmd -q --permanent --remove-service={dhcpv6-client,ssh}

	# apply & save configuration
	cmd firewall-cmd -q --reload
	cmd firewall-cmd -q --runtime-to-permanent

	Msg.info "Firewall installation and configuration completed!"
}	# end Install.firewalld


Install.firewall() {
	# installing firewall, using ufw
	# $1 - ssh port number, optional
	SSHD_PORT=$( Port.audit ${1:-$SSHD_PORT} )	# strictly numeric port

	# install required software
	Pkg.requires ufw

	# enable service so it can be loaded at every boot
	cmd ufw --force enable
	cmd systemctl enable ufw
	cmd ufw allow $SSHD_PORT/tcp

	# save back configuration
	Config.set "SSHD_PORT" "$SSHD_PORT"

	Msg.info "Firewall installation and configuration completed!"
}	# end Install.firewall


Menu.firewall() {
	# reload configuration
	cmd firewall-cmd --list-all
}	# end Menu.firewall


Fw.allow() {
	# enable services on firewalld
	# $1 - keyword mapped to a Fw.rule.<keyword> function
	Arg.expect "$1" || return

	# unique-ize valid arguments
#	local a w
#	for w in $FW_allowed $@; do
#		! Element.in $w $a && Cmd.usable "Fw.rule.$w" && a+=" $w"
#	done

	# save the new value back into the main lib.sh file
#	Fw.write "$SSHD_PORT" "${a:1}"

	# load configured rules on system
#	Menu.firewall 'start'



	# reload configuration
	cmd firewall-cmd -q --reload
	cmd firewall-cmd -q --runtime-to-permanent
};	# end Fw.allow
