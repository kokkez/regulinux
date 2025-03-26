# ------------------------------------------------------------------------------
# install filemaker server 20 on ubuntu 20.04 focal
# ------------------------------------------------------------------------------

fms.ssl() {
	# install letsencrypt ssl certificate
	local ssl r=/opt/FileMaker	# fm root
	ln -nfs "$r/FileMaker Server/NginxServer/htdocs/httpsRoot" "$r/webroot"

	# get cert from letsencrypt
	curl https://get.acme.sh | bash
	ssl=~/.acme.sh/acme.sh
	ssl --set-default-ca --server letsencrypt
	ssl --register-account -m $LENC_MAIL
	ssl --issue -d $HOST_FQDN -w "$r/webroot"
	r="/opt/FileMaker/FileMaker Server/CStore"
	ssl --install-cert -d $HOST_FQDN \
	  --key-file       "$r/le-keyfile.key"  \
	  --fullchain-file "$r/le-fullchain.crt"

	# install cert & restart server
	cd "$r"
	fmsadmin certificate import ./le-fullchain.crt \
	  --keyfile ./le-keyfile.key -u admin -p bamalama -y
	fmsadmin restart adminserver -u admin -p bamalama -y
	fmsadmin restart server -u admin -p bamalama -y
	service fmshelper --full-restart
}	# end fms.ssl
Menu.acme()  { fms.ssl "$@"; }	# alias fn


fms.firewall() {
	# post installation cleaning

	# stopping & disabling firewalld
	Msg.info "Stopping and disabling firewalld..."
	systemctl stop firewalld
	systemctl disable firewalld

	# conditional install ufw firewall
	Pkg.requires ufw

	# configuring ufw
	Msg.info "Configuring ufw firewall..."
	ufw allow $SSHD_PORT/tcp
	ufw allow 5003/tcp
	ufw allow 2399/tcp
	ufw allow 443/tcp
	ufw allow 80/tcp
	ufw --force enable
	ufw status verbose

	# add symlink to databases folder in root home
	Msg.info "Creating symlink to databases folder in home..."
	ln -nfs "/opt/FileMaker/FileMaker Server/Data/Databases" ~/fmdb
}	# end fms.firewall


fms.install() {
	# filemaker server full installation
	local u="$1" d=$(mktemp -d)	# temporary folder

	# conditional install required packages
	Pkg.requires unzip wget libxt6

	# download & unzip filemaker server
	Msg.info "Downloading FileMaker Server..."
	cd "$d"
	File.download "$u" fms.zip
	unzip fms.zip

	# populating "Assisted Install"
	cat > "Assisted Install.txt" <<- EOF
		[Assisted Install]
		License Accepted=1
		Deployment Options=0
		Admin Console User=admin
		Admin Console Password=bamalama
		Admin Console PIN=9417
		License Certificate Path=
		Filter Databases=0
		Remove Desktop Shortcut=0
		Remove Sample Database=0
		EOF

	# do the real installation
	Msg.info "Installing FileMaker Server..."
	apt update
	FM_ASSISTED_INSTALL="$d" apt -y install ./filemaker-*.deb
}	# end fms.install


Menu.fms() {
	# install filemaker server
#	local u d v=21.0.2.202	# version to install
	local u d v=21.1.3.305	# version to install
	d=/opt/FileMaker		# directory root
#	u="https://cloud.italmedia.net/s/nWKTYQfdJmZzEwk/download/fms_${v}_Ubuntu20_amd64.zip"	# directory root
	u="https://cloud.italmedia.net/s/T8Aiqmb9TzgRByq/download/fms_${v}_Ubuntu20_amd64.zip"	# directory root

	# test if filemaker server is already installed
	[ -d "$d" ] && [ "$(ls -A "$d")" ] && {
		Msg.warn "FileMaker Server $v is already installed in ${d}..."
		return
	}

	fms.install "$u"
	fms.firewall
	cd
}	# end Menu.fms
