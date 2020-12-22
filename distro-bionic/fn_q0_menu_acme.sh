# ------------------------------------------------------------------------------
# install acme.sh to manage Let's Encrypt free SSL certificates
# ------------------------------------------------------------------------------

acme_get() {
	# get acme.sh script (https://github.com/Neilpang/acme.sh)
	cd; wget -O -  https://get.acme.sh | bash
	bash ~/.acme.sh/acme.sh --registeraccount --accountemail ${LENC_MAIL} --log --log-level 2
}	# end acme_get


acme_conf() {
	# saves the apache configuration file for letsencrypt
	cat > ${1} <<EOF
# Apache configuration for letsencrypt acme-challenge
# /.well-known/acme-challenge/${2}

Alias /.well-known/acme-challenge /var/www/le-challenge/

<Directory /var/www/le-challenge/>
	${3}
	FallbackResource index.php
</Directory>
EOF
}	# end acme_conf


acme_thumbprint() {
	# get the value of ACCOUNT_THUMBPRINT from the log
	local THU LOG=~/.acme.sh/acme.sh.log
	[ -e "${LOG}" ] && {
		THU=$(awk -F\' '/HUMB/{print $2}' ${LOG})
		echo "${THU}"
	}
}	# end acme_thumbprint


acme_index() {
	# it echo the index page with the passed thumbprint
	local THU=$(acme_thumbprint)
	[ -z "${THU}" ] || {
		cat > ${1} <<EOF
<?php // outputting as text
header('Content-Type: text/plain');
echo basename(\$_SERVER['REQUEST_URI']) .".${THU}\n";
EOF
		msg_info "The ACCOUNT_THUMBPRINT value is: ${THU}"
	}
}	# end acme_index


acme_ic31() {
	# detected ispconfig 3.1
	cd /usr/local/ispconfig/interface/acme/.well-known/acme-challenge
	acme_index "index.php"
	cd /etc/apache2/sites-available
	sed -i '/nge>/a\\tFallbackResource index.php' ispconfig.conf
}	# end acme_ic31


acme_ic30() {
	# creating the PHP response file
	mkdir -p /var/www/le-challenge && cd "$_"
	local THU=$(acme_thumbprint)
	acme_index "index.php"

	# creating the apache configuration file
	cd /etc/apache2
	local DTV="Allow from all"
	[ -d conf-available ] && DTV="Require all granted"
	acme_conf "acme-challenge.conf" "${THU}" "${DTV}"

	# install into sites-available of apache2
	[ -L sites-enabled/010-acme-challenge.conf ] || {
		ln -s ../acme-challenge.conf sites-enabled/010-acme-challenge.conf
	}
}	# end acme_ic30










acme_webroot() {
	# returns the webroot for the acme.sh script
	[ -d /usr/local/ispconfig/interface/acme ] && {
		echo "/usr/local/ispconfig/interface/acme"	# ispconfig 3.1 webroot
	} || {
		echo "/var/www/acme-webroot"				# default webroot
	}
}	# end acme_webroot


acme_webserver_conf() {
	# install configurations for webserver
	if [ "${HTTP_SERVER}" = "nginx" ]; then
		copy_to /etc/nginx/snippets acme/acme-webroot-nginx.conf
		svc_evoke nginx restart
	else
		HTTP_SERVER="apache2"
		#copy_to /etc/apache2 acme/acme-webroot-apache2.conf
		svc_evoke apache2 restart
	fi;
}	# end acme_webserver_conf


acme_paths_conf() {
	# adjust paths to points to those of the acme certificates
	# $1 - path to server key
	# $2 - path to server certificate
	local P

	# ispconfig paths
	[ -d /usr/local/ispconfig/interface/ssl ] && {
		cd /usr/local/ispconfig/interface/ssl
		is_symlink 'ispserver.key' || {
			mv -f ispserver.key ispserver.key.bak
			ln -s ${1} ispserver.key
		}
		is_symlink 'ispserver.crt' || {
			mv -f ispserver.crt ispserver.crt.bak
			ln -s ${2} ispserver.crt
		}
	}

	# nginx paths
	[ -d /etc/nginx ] && {
		svc_evoke nginx restart
	}

	# apache2 paths
	[ -d /etc/apache2 ] && {
		cd /etc/apache2
		P=sites-available/default-ssl
		[ -s "${P}.conf" ] && P="${P}.conf"
		[ -s "${P}" ] && {
			sed -ri ${P} \
				-e "s|^(\s*SSLCertificateFile).*|\1 ${2}|" \
				-e "s|^(\s*SSLCertificateKeyFile).*|\1 ${1}|"
			# adjust symlink
			is_symlink sites-enabled/0000-default-ssl.conf || {
				ln -s ../${P} sites-enabled/0000-default-ssl.conf
				rm -rf sites-enabled/default-ssl*
			}
			# enable related apache2 modules
			a2enmod rewrite headers ssl
		}
		P=sites-available/ispconfig.vhost
		[ -s "${P}" ] && {
			sed -ri ${P} \
				-e "s|^(\s*SSLCertificateFile).*|\1 ${2}|" \
				-e "s|^(\s*SSLCertificateKeyFile).*|\1 ${1}|"
		}
		svc_evoke apache2 restart		# restarting apache
	}
}	# end acme_paths_conf


menu_acme() {
	# do nothing if already installed
	[ -d ~/.acme.sh ] && {
		msg_alert "The acme.sh script is already installed..."
		return
	}

	# get acme.sh script
	msg_info "Installing acme.sh script..."
	acme_get

	# get the webroot
	local K C W=$(acme_webroot)

	# creating the full path to the challenge folder
	mkdir -p "${W}/.well-known/acme-challenge"
	acme_webserver_conf

	# issue the cert
	K=/etc/ssl/myserver/server.key
	C=/etc/ssl/myserver/server.cert
	mkdir -p /etc/ssl/myserver

	bash ~/.acme.sh/acme.sh --issue --test -d "${HOST_FQDN}" -w "${W}"
	[ "$?" -eq 0 ] || return	# dont continue on error

	bash ~/.acme.sh/acme.sh --installcert -d "${HOST_FQDN}" \
		--keypath "${K}" \
		--fullchainpath "${C}" \
		--reloadcmd "systemctl restart ${HTTP_SERVER}"

	acme_paths_conf "${K}" "${C}"
	msg_info "Installation of acme.sh completed!"
}	# end menu_acme
