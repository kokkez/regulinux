# ------------------------------------------------------------------------------
# install AntiSpam SMTP Proxy v1.10.1_16065 with perl 5.26 for ubuntu 18.04
# ------------------------------------------------------------------------------

install_assp() {
	cd /home
	local u="https://sourceforge.net/projects/assp/files"

	# download & install ASSP
	[ -s assp/assp.cfg ] || {
		Msg.info "Installing ASSP v1..."
		# download ASSP
		File.download "${u}/ASSP%20Installation/ASSP%201.10.X/ASSP_1.10.1_16065_install.zip" assp.zip
		# some cleanup
		unzip assp.zip
		mv ASSP_*/ASSP assp
		rm -rf *.zip ASSP_*
		cd /home/assp
		chmod +x assp.pl
		rm -rf assp.cfg* addservice* resendmail virusscan
	}

	# install some required perl modules before run mod_inst.pl
	Msg.info "Installing ASSP dependencies..."
	Pkg.install perl perl-base perl-modules build-essential libssl-dev \
		libnet-dns-perl libio-compress-perl libemail-mime-modifier-perl \
		libemail-sender-perl libemail-valid-perl libfile-readbackwards-perl \
		libio-socket-inet6-perl libio-socket-ssl-perl libmail-dkim-perl \
		libmail-spf-perl libmail-srs-perl libnet-cidr-lite-perl \
		libnet-ldap-perl libnet-smtp-ssl-perl libsys-syslog-perl \
		libmail-checkuser-perl libtie-dbi-perl libauthen-sasl-perl \
		libdevel-size-perl liblwp-protocol-https-perl
	# libsys-meminfo-perl

	# try unattended
	export PERL_MM_USE_DEFAULT=1	# to respond yes
	perl -MCPAN -e 'install CPAN'
	perl -MCPAN -e 'reload cpan'
	cmd cpan "Error" "Sys::MemInfo" "Crypt::CBC" "Crypt::OpenSSL::AES" "Convert::Scalar"
	perl -MCPAN -e 'force install Mail::SPF::Query'

	# run mod_inst.pl to install other perl modules
	perl mod_inst.pl /home/assp

	Msg.info "Installing ASSP dependencies completed!"
	Msg.info "Remember to run twice 'perl mod_inst.pl'..."

	# force unix EOLs & adjust some values
	cd /home/assp
	File.place assp/assp1.cfg ./assp.cfg
	sed -i rc/_etc_* \
		-e 's|\r||g'
	sed -i rc/_etc_default_assp.debian \
		-e 's|srv|home|;s|assp\.pid|pid|'
	sed -i assp.cfg \
		-e "s|HOST_NICK|$HOST_NICK|g" \
		-e "s|LOG_PREFIX|${HOST_NICK:0:3}|g" \
		-e "s|IP_ADDRESS|$( cmd hostname -i )|g"

	# configure assp for autostart
	cp rc/_etc_def* /etc/default/assp
	cp rc/_etc_ini* /etc/init.d/assp
	cmd chmod +x /etc/init.d/assp
	cmd update-rc.d assp defaults

	# systemd
	[ -s /etc/systemd/system/assp.service ] || {
		File.into /etc/systemd/system assp/assp.service
		cmd systemctl enable assp.service
		cmd systemctl daemon-reload
	}

	# creating a new database, then load from file
	Create.database "assp" "assp" "$ASSP_ADMINPW"
	cmd mysql 'assp' < $( File.path assp/assp.sql )

	# activating ports on firewall
	Fw.allow 'smtp assp'

	# courtesy symlink into ~
	ln -nfs /home/assp ~

	Msg.info "Installing ASSP completed!"
	Msg.info "Check carefully every single perl module before start ASSP..."
}	# end install_assp
