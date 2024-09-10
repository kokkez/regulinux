# ------------------------------------------------------------------------------
# install filemaker server 20 on ubuntu 20.04 focal
# ------------------------------------------------------------------------------

fms.cleanup() {
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
}	# end fms.cleanup


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
	local u d v=20.3.2.205	# version to install
	d=/opt/FileMaker		# directory root
	u="https://cloud.italmedia.net/s/we7yZ3DGBR8srPJ/download/fms_20.3.2.205_Ubuntu20_amd64.zip"	# directory root

	# test if filemaker server is already installed
	[ -d "$d" ] && [ "$(ls -A "$d")" ] && {
		Msg.warn "FileMaker Server $v is already installed in ${d}..."
		return
	}

	fms.install "$u"
	fms.cleanup
}	# end Menu.fms
