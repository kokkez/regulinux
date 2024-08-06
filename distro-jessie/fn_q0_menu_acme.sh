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
		Msg.info "The ACCOUNT_THUMBPRINT value is: ${THU}"
	}
}	# end acme_index


acme_ic31() {
	# detected ispconfig 3.1
	cd /usr/local/ispconfig/interface/acme/.well-known/acme-challenge
	acme_index "index.php"
	sed -i /etc/apache2/sites-available/ispconfig.conf
		-e '/nge>/a\\tFallbackResource index.php'
}	# end acme_ic31


acme_ic30() {
	# creating the PHP response file
	mkdir -p /var/www/le-challenge && cd "$_"
	local THU=$(acme_index "index.php")

	# creating the apache configuration file
	cd /etc/apache2
	local DTV="Allow from all"
	[ -d conf-available ] && DTV="Require all granted"
	acme_conf "acme-challenge.conf" "${THU}" "${DTV}"

	# install into sites-available of apache2
	[ -L sites-enabled/000-acme-challenge.conf ] || {
		ln -s ../sites-available/acme-challenge.conf sites-enabled/000-acme-challenge.conf
	}
}	# end acme_ic30


Menu.acme() {
	# do nothing if already installed
	[ -d ~/.acme.sh ] && {
		Msg.warn "The acme.sh script is already installed..."
		return
	}

	# get acme.sh script
	Msg.info "Installing acme.sh script..."
	acme_get

	# detect ispconfig version 3.1
	[ -d /usr/local/ispconfig/interface/acme/.well-known/acme-challenge ] && {
		acme_ic31
	} || {
		acme_ic30
	}
	svc_evoke apache2 restart	# require an apache restart

	# issue the cert
	local k c p
	k=/etc/ssl/myserver/server.key
	c=/etc/ssl/myserver/server.cert
	mkdir -p /etc/ssl/myserver

	bash ~/.acme.sh/acme.sh --issue --stateless -d "$HOST_FQDN"
	[ "$?" -eq 0 ] || return	# abort on error

	bash ~/.acme.sh/acme.sh --installcert -d "$HOST_FQDN" \
		--keypath "$k" \
		--fullchainpath "$c" \
		--reloadcmd "systemctl restart apache2"

	# edit /etc/apache2/sites-available/default-ssl
	cd /etc/apache2
	p=sites-available/default-ssl
	[ -s "$p.conf" ] && p="$p.conf"
	[ -s "$p" ] && {
		#	SSLCertificateFile		/etc/ssl/myserver/server.cert
		#	SSLCertificateKeyFile	/etc/ssl/myserver/server.key
		sed -ri $p \
			-e "s|^(\s*SSLCertificateFile).*|\1 $c|" \
			-e "s|^(\s*SSLCertificateKeyFile).*|\1 $k|"

		# enable related apache2 modules & site
		[ -L sites-enabled/0000-default-ssl.conf ] || {
			ln -s ../$p sites-enabled/0000-default-ssl.conf
			rm -rf sites-enabled/default-ssl*
		}
		a2enmod rewrite headers ssl
	}
	p=sites-available/ispconfig.vhost
	[ -s "$p" ] && {
		sed -ri $p \
			-e "s|^(\s*SSLCertificateFile).*|\1 $c|" \
			-e "s|^(\s*SSLCertificateKeyFile).*|\1 $k|"
	}
	service apache2 restart		# restarting apache

	Msg.info "Installation of acme.sh completed!"
}	# end Menu.acme
