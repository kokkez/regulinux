# ------------------------------------------------------------------------------
# install control panel ispconfig 3.1
# IspConfig 3.1.13:   2018-10-21
# IspConfig 3.1.13p1: 2019-04-23
# IspConfig 3.1.14p2: 2019-08-04
# IspConfig 3.1.15:   2019-09-15
# IspConfig 3.1.15p2: 2019-11-10
# IspConfig 3.1.15p3: 2020-02-24
# ------------------------------------------------------------------------------

install_ispconfig() {
	local m u v="3.1.15p3" # version to install
	Msg.info "Installing IspConfig ${v}..."

	cd /tmp
	u=https://www.ispconfig.org/downloads/ISPConfig-${v}.tar.gz
	File.download "$u" "isp3.tar.gz"
	tar xzf isp3.tar.gz
	cd ispconfig3*/install/

	[ -s autoinstall.ini ] || {
		[ "$ISP3_MULTISERVER" = "y" ] && m="expert"

		File.place ispconfig/autoinstall.ini.3.1 autoinstall.ini
		sed -ri autoinstall.ini \
			-e "s/^(install_mode=).*/\1${m:-standard}/" \
			-e "s/^(hostname=).*/\1${HOST_FQDN}/" \
			-e "s/^(mysql_root_password=).*/\1${DB_rootpw}/g" \
			-e "s/^(ssl_cert_country=).*/\1${CERT_C}/" \
			-e "s/^(ssl_cert_state=).*/\1${CERT_ST}/" \
			-e "s/^(ssl_cert_locality=).*/\1${CERT_L}/" \
			-e "s/^(ssl_cert_organisation=).*/\1${CERT_O}/" \
			-e "s/^(ssl_cert_organisation_unit=).*/\1${CERT_OU}/" \
			-e "s/^(ssl_cert_common_name=).*/\1${CERT_CN}/" \
			-e "s/^(ssl_cert_email=).*/\1${CERT_E}/" \
			-e "s/^(mysql_ispconfig_password=).*/\1$( Pw.generate )/" \
			-e "s/^(join_multiserver_setup=).*/\1${ISP3_MULTISERVER}/" \
			-e "s/^(mysql_master_hostname=).*/\1${ISP3_MASTERHOST}/g" \
			-e "s/^(mysql_master_root_user=).*/\1${ISP3_MASTERUSER}/g" \
			-e "s/^(mysql_master_root_password=).*/\1${ISP3_MASTERPASS}/g"
	}
	cmd php -q install.php --autoinstall=autoinstall.ini

	# on apache 2.4 we connect to ispconfig thru port 8080
	mkdir -p /var/www/html/ispconfig && cd "$_"
	File.into . ispconfig/index.php

	# load a customized database dbispconfig
	u=$( File.path ispconfig/dbispconfig-${v}.sql )
	[ -n "$u" ] && cmd mysql 'dbispconfig' < $u

	# commenting lines in 2 new files of postfix
	sed -i /etc/postfix/tag_as_*.re -e 's|^#*|#|'

	# activating ports on firewall
	Fw.allow 'ispconfig'

	# cleanup
	rm -rf /tmp/*
	Msg.info "Installation of IspConfig $v completed!"
}	# end install_ispconfig
