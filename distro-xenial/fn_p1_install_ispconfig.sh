# ------------------------------------------------------------------------------
# install control panel ispconfig 3.1
# IspConfig 3.1.13: 2018-10-21
# IspConfig 3.1.13p1: 2019-04-23
# IspConfig 3.1.14p2: 2019-08-04
# IspConfig 3.1.15p2: 2019-11-10
# IspConfig 3.1.15p3: 2020-02-24
# ------------------------------------------------------------------------------

install_ispconfig() {
	local U V="3.1.15p3" # version to install
	Msg.info "Installing IspConfig ${V}..."

	cd /tmp
	U=https://www.ispconfig.org/downloads/ISPConfig-${V}.tar.gz
	down_load "${U}" "isp3.tar.gz"
	tar xzf isp3.tar.gz
	cd ispconfig3*/install/

	[ -s autoinstall.ini ] || {
		[ "${ISP3_MULTISERVER}" = "y" ] && MOD="expert" || MOD="standard"

		do_copy ispconfig/autoinstall.ini.3.1 autoinstall.ini
		sed -ri autoinstall.ini \
			-e "s/^(install_mode=).*/\1${MOD}/" \
			-e "s/^(hostname=).*/\1${HOST_FQDN}/" \
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

	# on apache 2.4 we connect to ispconfig thru port 8080
	mkdir -p /var/www/html/ispconfig && cd "$_"
	copy_to . ispconfig/index.php

	# load a customized database dbispconfig
	cd ${ENV_files}/ispconfig
	[ -f "dbispconfig-${V}.sql" ] && cmd mysql 'dbispconfig' < dbispconfig-${V}.sql

	# commenting lines in 2 new files of postfix
	sed -i 's|^#*|#|' /etc/postfix/tag_as_*.re

	# activating ports on firewall
	firewall_allow "ispconfig"

	# cleanup
	rm -rf /tmp/*
	Msg.info "Installation of IspConfig ${V} completed!"
}	# end install_ispconfig
