# ------------------------------------------------------------------------------
# install postfix mailserver
# ------------------------------------------------------------------------------

install_postfix() {
	Pkg.installed "postfix-mysql" && {
		Msg.warn "Postfix is already installed..."
		return
	}

	# install postfix & saslauthd, this add openssl ssl-cert
	Msg.info "Installing postfix for ${ENV_os}..."

	# preseed postfix
	debconf-set-selections <<EOF
postfix postfix/main_mailer_type select Internet Site
postfix postfix/mailname string $MAIL_NAME
postfix postfix/destinations string \$myorigin,localhost
EOF

	# install required & useful packages
	Pkg.install postfix postfix-mysql libsasl2-modules pfqueue swaks

	Msg.info "Configuring Postfix..."

	# set basic parameters in main.cf
	cmd postconf \
		myhostname=$MAIL_NAME \
		myorigin=\$myhostname \
		mydestination=\$myorigin,localhost

	# install /etc/aliases
	File.into /etc postfix/aliases
	sed -i /etc/aliases -e "s|ROOT_MAIL|$ROOT_MAIL|"
	cmd newaliases

	# activating ports on firewall
	Firewall.allow 'ssltls'

	Msg.info "Installation of postfix & aliases completed!"
}	# end install_postfix
