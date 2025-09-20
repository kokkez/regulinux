# ------------------------------------------------------------------------------
# install acme.sh to manage Let's Encrypt free SSL certificates
# ------------------------------------------------------------------------------

acme.issue() {
	# issue and install certififcate
	# $1 - the webroot for acme.sh
	# $2 - optional hostname, defaults do HOST_FQDN
	local d k c h=${2:-$HOST_FQDN}
	d=/etc/ssl/myserver
	k=$d/server.key
	c=$d/server.cert
	mkdir -p $d
	# issue cert
	#bash ~/.acme.sh/acme.sh --issue --test -d "$h" -w "$1"
	bash ~/.acme.sh/acme.sh --issue -d "$h" -w "$1"
	(( $? )) && {				# dont continue on error
		Msg.error "acme.sh issue failed"
		return 1
	}
	# install cert
	bash ~/.acme.sh/acme.sh --installcert -d "$h" \
		--keypath "$k" \
		--fullchainpath "$c" \
		--reloadcmd "systemctl restart $HTTP_SERVER"
	# symlink the certificate paths
	sslcert_paths "$k" "$c"
}	# end acme.issue


acme.prepare() {
	# prepare configurations for webserver
	# $1 - the webroot for acme.sh
	[ -d "$1" ] || {
		Msg.error "invalid webroot: $1"
		return 1
	}
	# creating the full path to the challenge folder
	mkdir -p "$1/.well-known/acme-challenge"
	local d f

	if [ "${HTTP_SERVER}" = "nginx" ]; then
		d=/etc/nginx/snippets
		f=acme-webroot-nginx.conf
		File.into $d acme/$f
		sed -i $d/$f -e "s|WEBROOT|$1|g"
		systemctl restart nginx
	else
		HTTP_SERVER="apache2"
		(( ${#1} < 22 )) && {
			d=/etc/apache2/conf-available
			f=acme-webroot-apache2.conf
			File.into $d acme/$f
			sed -i $d/$f -e "s|WEBROOT|$1|g"
			ln -nfs '../conf-available/acme-webroot-apache2.conf' /etc/apache2/conf-enabled/webroot-apache2.conf
		}
		systemctl restart apache2
	fi
}	# end acme.prepare


acme.webroot() {
	# returns the webroot for the acme.sh script
	local r=/usr/local/ispconfig/interface/acme		# ispconfig 3.1+ webroot
	ISPConfig.installed || r=/var/www/acme-webroot	# older webroot
	echo "$r"
}	# end acme.webroot


acme.get() {
	# get acme.sh script (https://github.com/Neilpang/acme.sh)
	cd
	wget -O - https://get.acme.sh | bash
	bash ~/.acme.sh/acme.sh --server letsencrypt \
		--registeraccount --accountemail $LENC_MAIL \
		--log --log-level 2
}	# end acme.get


Menu.issue() {
	# metadata for OS.menu entries
	__exclude='[ ! -d ~/.acme.sh/$HOST_FQDN_ecc ]'
	__section='Others applications'
	__summary="issue & install a free SSL certificate for $(Dye.fg.white $HOST_FQDN)"

	# issue & install cert
	local w=$( acme.webroot ) h=${1:-$HOST_FQDN}
	acme.issue "$w" "$h" || return
	Msg.info "Installation of SSL certificate for '$(Dye.fg.white $h)' completed!"
}	# end acme.get


Menu.acme() {
	# metadata for OS.menu entries
	__exclude='[ -d ~/.acme.sh ]'
	__section='Others applications'
	__summary="shell script for $(Dye.fg.white Let\`s Encrypt) free SSL certificates"

	# do nothing if already installed
	[ -d ~/.acme.sh ] && {
		Msg.warn "The acme.sh script is already installed..."
		return
	}

	# get acme.sh script
	Msg.info "Installing acme.sh script..."
	acme.get

	# get the webroot
	local w=$( acme.webroot )
	acme.prepare "$w" || return

	# issue & install cert
	acme.issue "$w" || return

	Msg.info "Installation of acme.sh completed!"
}	# end Menu.acme
