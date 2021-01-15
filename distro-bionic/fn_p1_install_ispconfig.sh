# ------------------------------------------------------------------------------
# install control panel ispconfig 3.1
# IspConfig 3.1.15p3: 2020-02-24
# ------------------------------------------------------------------------------

install_ispconfig() {
	local M U V="3.1.15p3" # version to install
	msg_info "Installing IspConfig ${V}..."

	cd /tmp
	U=https://www.ispconfig.org/downloads/ISPConfig-${V}.tar.gz
	down_load "${U}" "isp3.tar.gz"
	tar xzf isp3.tar.gz
	cd ispconfig3*/install/

	[ -s autoinstall.ini ] || {
		[ "${ISP3_MULTISERVER}" = "y" ] && M="expert"

		do_copy ispconfig/autoinstall.ini.3.2 autoinstall.ini
		sed -ri autoinstall.ini \
			-e "s/^(install_mode=).*/\1${M:-standard}/" \
			-e "s/^(hostname=).*/\1${HOST_FQDN}/" \
			-e "s/^(http_server=).*/\1${HTTP_SERVER:-apache}/" \
			-e "s/^(mysql_root_password=).*/\1${DB_ROOTPW}/g" \
			-e "s/^(ssl_cert_country=).*/\1${CERT_C}/" \
			-e "s/^(ssl_cert_state=).*/\1${CERT_ST}/" \
			-e "s/^(ssl_cert_locality=).*/\1${CERT_L}/" \
			-e "s/^(ssl_cert_organisation=).*/\1${CERT_O}/" \
			-e "s/^(ssl_cert_organisation_unit=).*/\1${CERT_OU}/" \
			-e "s/^(ssl_cert_common_name=).*/\1${CERT_CN}/" \
			-e "s/^(ssl_cert_email=).*/\1${CERT_E}/" \
			-e "s/^(mysql_ispconfig_password=).*/\1$(menu_password)/" \
			-e "s/^(join_multiserver_setup=).*/\1${ISP3_MULTISERVER}/" \
			-e "s/^(mysql_master_hostname=).*/\1${ISP3_MASTERHOST}/g" \
			-e "s/^(mysql_master_root_user=).*/\1${ISP3_MASTERUSER}/g" \
			-e "s/^(mysql_master_root_password=).*/\1${ISP3_MASTERPASS}/g"
	}
	cmd php -q install.php --autoinstall=autoinstall.ini

	# shortcut to connect to ispconfig thru port 8080
	if [ "${HTTP_SERVER}" = "nginx" ]; then
		copy_to /etc/nginx/snippets ispconfig/ispconfig-nginx.conf
		cmd systemctl restart nginx
	else
		# apache2
		mkdir -p /var/www/html/ispconfig && cd "$_"
		copy_to . ispconfig/index.php
	fi;

	# load a customized database into dbispconfig
	U=$(my_path ispconfig/dbispconfig-${V}.sql)
	[ -n "${U}" ] && {
		[ "${HTTP_SERVER}" = "nginx" ] && sed -i 's|=apache\\|=nginx\\|g' ${U}
		cmd mysql 'dbispconfig' < ${U}
	}

	# postfix
	# comment lines in 2 files of postfix
	sed -i 's|^#*|#|' /etc/postfix/tag_as_*.re
	cmd postconf mydestination='$myorigin, localhost'
	cmd postconf -# relayhost smtpd_restriction_classes greylisting
	U=/etc/postfix/main.cf
	grep -q 'relaying' ${U} || {
		M="### ----------------------------------------------------------------------------
### relaying via an external SMTP
### ----------------------------------------------------------------------------
smtp_sasl_auth_enable = yes
smtp_always_send_ehlo = yes
smtp_sasl_security_options = noanonymous
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
relayhost = [smtp-e.rete.us]:587
smtp_fallback_relay = [smtp-m.rete.us]:587
### ----------------------------------------------------------------------------\n"
		perl -i -pe "s|# TLS|${M}\n# TLS|g" ${U}
	}
	copy_to /etc/postfix/ postfix/sasl_passwd
	cmd systemctl restart postfix

	# symlink the certificate paths
	[ -d /etc/ssl/myserver ] && {
		U=/etc/ssl/myserver/server
		sslcert_paths "${U}.key" "${U}.cert"
	}

	# activating ports on firewall
	firewall_allow "ispconfig"

	# cleanup
	rm -rf /tmp/*
	msg_info "Installation of IspConfig ${V} completed!"
}	# end install_ispconfig
