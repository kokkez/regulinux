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

		do_copy ispconfig/autoinstall.ini.3.1 autoinstall.ini
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
		U=/etc/nginx/sites-available/default
		grep -q 'ispconfig' ${U} || {
			sed -ri ${U} \
				-e 's|_;|_;\n\trewrite /ispconfig/ https://$host:8080 permanent;|'
		}
	else
		# apache2
		mkdir -p /var/www/html/ispconfig && cd "$_"
		copy_to . ispconfig/index.php
	fi;

	# load a customized database into dbispconfig
	U=$(detect_path ispconfig/dbispconfig-${V}.sql)
	[ -n "${U}" ] && {
		[ "${HTTP_SERVER}" = "nginx" ] && sed -ri ${U} -e 's|=apache\\|=nginx\\|'
		cmd mysql 'dbispconfig' < ${U}
	}

	# commenting lines in 2 new files of postfix
	sed -i 's|^#*|#|' /etc/postfix/tag_as_*.re

	# activating ports on firewall
	firewall_allow "ispconfig"

	# cleanup
	rm -rf /tmp/*
	msg_info "Installation of IspConfig ${V} completed!"
}	# end install_ispconfig
