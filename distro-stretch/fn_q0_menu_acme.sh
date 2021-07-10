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
	has_ispconfig && {
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
		cmd systemctl restart nginx
	else
		HTTP_SERVER="apache2"
		(( ${#1} < 22 )) && {
			cd /etc/apache2/conf-available
			copy_to . acme/acme-webroot-apache2.conf
			sed -i "s|WEBROOT|${1}|g" acme-webroot-apache2.conf
			ln -nfs '../conf-available/acme-webroot-apache2.conf' /etc/apache2/conf-enabled/webroot-apache2.conf
		}
		cmd systemctl restart apache2
	fi;
}	# end acme_webserver_conf


menu_acme() {
	# do nothing if already installed
	[ -d ~/.acme.sh ] && {
		Msg.warn "The acme.sh script is already installed..."
		return
	}

	# get acme.sh script
	Msg.info "Installing acme.sh script..."
	acme_get

	# get the webroot
	local K C W=$(acme_webroot)
	acme_webserver_conf "${W}"

	# issue the cert
	K=/etc/ssl/myserver/server.key
	C=/etc/ssl/myserver/server.cert
	mkdir -p /etc/ssl/myserver

	#bash ~/.acme.sh/acme.sh --issue --test -d "${HOST_FQDN}" -w "${W}"
	bash ~/.acme.sh/acme.sh --issue -d "${HOST_FQDN}" -w "${W}"
	[ "$?" -eq 0 ] || return	# dont continue on error

	bash ~/.acme.sh/acme.sh --installcert -d "${HOST_FQDN}" \
		--keypath "${K}" \
		--fullchainpath "${C}" \
		--reloadcmd "systemctl restart ${HTTP_SERVER}"

	# symlink the certificate paths
	sslcert_paths "${K}" "${C}"

	Msg.info "Installation of acme.sh completed!"
}	# end menu_acme
