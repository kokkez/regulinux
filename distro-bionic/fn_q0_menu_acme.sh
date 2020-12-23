# ------------------------------------------------------------------------------
# install acme.sh to manage Let's Encrypt free SSL certificates
# ------------------------------------------------------------------------------

acme_get() {
	# get acme.sh script (https://github.com/Neilpang/acme.sh)
	cd; wget -O -  https://get.acme.sh | bash
	bash ~/.acme.sh/acme.sh --registeraccount --accountemail ${LENC_MAIL} --log --log-level 2
}	# end acme_get


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
	# $1 - the webroot for acme.sh

	# creating the full path to the challenge folder
	mkdir -p "${1}/.well-known/acme-challenge"

	if [ "${HTTP_SERVER}" = "nginx" ]; then
		cd /etc/nginx/snippets
		copy_to . acme/acme-webroot-nginx.conf
		sed -i "s|WEBROOT|${1}|g" acme-webroot-nginx.conf
		svc_evoke nginx restart
	else
		HTTP_SERVER="apache2"
		(( ${#1} < 22 )) && {
			cd /etc/apache2/conf-available
			copy_to . acme/acme-webroot-apache2.conf
			sed -i "s|WEBROOT|${1}|g" acme-webroot-apache2.conf
			ln -s '../conf-available/acme-webroot-apache2.conf' /etc/apache2/conf-enabled/webroot-apache2.conf
		}
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
		cd /etc/ssl/certs
		is_symlink 'ssl-cert-snakeoil.pem' || {
			mv -f ssl-cert-snakeoil.pem ssl-cert-snakeoil.pem.bak
			ln -s ${2} ssl-cert-snakeoil.pem
		}
		cd /etc/ssl/private
		is_symlink 'ssl-cert-snakeoil.key' || {
			mv -f ssl-cert-snakeoil.key ssl-cert-snakeoil.key.bak
			ln -s ${1} ssl-cert-snakeoil.key
		}
		# adjust default-ssl symlink
		cd /etc/apache2
		is_symlink sites-enabled/0000-default-ssl.conf || {
			ln -s ../sites-available/default-ssl.conf sites-enabled/0000-default-ssl.conf
			rm -rf sites-enabled/default-ssl*
		}
		# enable related modules, then restart apache2
		a2enmod rewrite headers ssl
		svc_evoke apache2 restart
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
	acme_webserver_conf "${W}"

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
