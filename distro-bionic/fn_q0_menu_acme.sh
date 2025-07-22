# ------------------------------------------------------------------------------
# install acme.sh to manage Let's Encrypt free SSL certificates
# ------------------------------------------------------------------------------

acme_get() {
	# get acme.sh script (https://github.com/Neilpang/acme.sh)
	cd; wget -O -  https://get.acme.sh | bash
	bash ~/.acme.sh/acme.sh --registeraccount --accountemail $LENC_MAIL --log --log-level 2
}	# end acme_get


acme_webroot() {
	# returns the webroot for the acme.sh script
	ISPConfig.installed && {
		echo "/usr/local/ispconfig/interface/acme"	# ispconfig 3.1 webroot
	} || {
		echo "/var/www/acme-webroot"				# default webroot
	}
}	# end acme_webroot


acme_webserver_conf() {
	# install configurations for webserver
	# $1 - the webroot for acme.sh

	# creating the full path to the challenge folder
	mkdir -p "$1/.well-known/acme-challenge"
	local d

	if [ "${HTTP_SERVER}" = "nginx" ]; then
		d=/etc/nginx/snippets
		File.into $d acme/acme-webroot-nginx.conf
		sed -i $d/acme-webroot-nginx.conf -e "s|WEBROOT|$1|g"
		cmd systemctl restart nginx
	else
		HTTP_SERVER="apache2"
		(( ${#1} < 22 )) && {
			d=/etc/apache2/conf-available
			File.into $d acme/acme-webroot-apache2.conf
			sed -i $d/acme-webroot-apache2.conf -e "s|WEBROOT|$1|g"
			ln -nfs '../conf-available/acme-webroot-apache2.conf' /etc/apache2/conf-enabled/webroot-apache2.conf
		}
		cmd systemctl restart apache2
	fi;
}	# end acme_webserver_conf


Menu.acme() {
	# metadata for OS.menu entries
	__exclude='[ -d ~/.acme.sh ]'
	__section='Others applications'
	__summary="shell script for $(Dye.fg.white Let\'s Encrypt) free SSL certificates"

	# do nothing if already installed
	[ -d ~/.acme.sh ] && {
		Msg.warn "The acme.sh script is already installed..."
		return
	}

	# get acme.sh script
	Msg.info "Installing acme.sh script..."
	acme_get

	# get the webroot
	local k c w=$( acme_webroot )
	acme_webserver_conf "$w"

	# issue the cert
	k=/etc/ssl/myserver/server.key
	c=/etc/ssl/myserver/server.cert
	mkdir -p /etc/ssl/myserver

	#bash ~/.acme.sh/acme.sh --issue --test -d "$HOST_FQDN" -w "$w"
	bash ~/.acme.sh/acme.sh --issue -d "$HOST_FQDN" -w "$w"
	[ "$?" -eq 0 ] || return	# dont continue on error

	bash ~/.acme.sh/acme.sh --installcert -d "$HOST_FQDN" \
		--keypath "$k" \
		--fullchainpath "$c" \
		--reloadcmd "systemctl restart $HTTP_SERVER"

	# symlink the certificate paths
	sslcert_paths "$k" "$c"

	Msg.info "Installation of acme.sh completed!"
}	# end Menu.acme
