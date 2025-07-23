# ------------------------------------------------------------------------------
# custom functions specific to debian 11 bullseye
# ------------------------------------------------------------------------------

Menu.apt() {
	# metadata for OS.menu entries
	__section='Standalone utilities'
	__summary="perform a full system upgrade via apt"

	Msg.info "Upgrading system packages for ${ENV_os}..."
	Pkg.update	# update packages lists

	# do the apt upgrade
	DEBIAN_FRONTEND=noninteractive apt -qy full-upgrade
}	# end Menu.apt


Net.if() {
	# return the name of the default network interface
	cmd ip r get 1 | cmd grep -oP 'dev \K\S+'
}	# end Net.if


Net.info() {
	# print parameters related to network: ip, gw, interface (default)
	local v=$(cmd ip a s scope global)

	if [[ "$1" == *6* ]]; then
		# check if IPv6 is enabled
		cmd grep -qP 'inet6 \K\S+' <<< "$v" || return
	fi
	case "$1" in
		cidr6*) v=$( cmd grep -oP 'inet6 \K\S+' <<< "$v" ) ;;
		cidr*)  v=$( cmd grep -oP 'inet \K\S+' <<< "$v" ) ;;
		gw6*)   v=$( cmd ip r get :: | cmd grep -oP 'via \K\S+' ) ;;
		gw*)    v=$( cmd ip r get 1 | cmd grep -oP 'via \K\S+' ) ;;
		ip6*)   v=$( Net.info cidr6 ); v="${v%%/*}" ;;
		ip*)    v=$( Net.info cidr ); v="${v%%/*}" ;;
		*)      v=$( cmd ip r get 1 | cmd grep -oP 'dev \K\S+' ) ;;
	esac
	echo "$v";
}	# Net.info


Repo.php() {
	# add external repository for updated php
	local p='/etc/apt/sources.list.d/php.list'
	[ -s "$p" ] && return

	# add external repository for updated php
	Pkg.requires apt-transport-https lsb-release ca-certificates
	File.download https://packages.sury.org/php/apt.gpg /etc/apt/trusted.gpg.d/php.gpg
	cat > "$p" <<-EOF
		# https://www.patreon.com/oerdnj
		deb http://packages.sury.org/php $ENV_codename main
		#deb-src http://packages.sury.org/php $ENV_codename main
		EOF
	# forcing apt update
	Pkg.update 'coerce'
}	# end Repo.php


Arrange.sshd() {
	# configure SSH server parameters
	# $1: ssh port number, optional
	SSHD_PORT=$( Port.audit ${1:-$SSHD_PORT} )
	cmd sed -ri /etc/ssh/sshd_config \
		-e "s|^#?(Port)\s.*|\1 $SSHD_PORT|" \
		-e 's|^#?(PasswordAuthentication)\s.*|\1 no|' \
		-e 's|^#?(PermitRootLogin)\s.*|\1 without-password|' \
		-e 's|^#?(RSAAuthentication)\s.*|\1 yes|' \
		-e 's|^#?(PubkeyAuthentication)\s.*|\1 yes|'
	cmd systemctl restart ssh
	Config.set "SSHD_PORT" "$SSHD_PORT"
	Msg.info "SSH server is now listening on port: $SSHD_PORT"
}	# end Arrange.sshd


Menu.distroup() {
	# upgrade the distro to debian 12 bookworm
	# no arguments expected
	if [ "$ENV_codename" = "bookworm" ]; then
		Msg.warn "Current distro is already $(Dye.fg.white $ENV_os), exiting..."
		return
	fi

	# full-upgrading one last time
	Msg.info "Updating $(Dye.fg.white $ENV_codename) before the upgrade..."
	cmd apt update && cmd apt upgrade -y && cmd apt full-upgrade -y && cmd apt --purge autoremove -y

	# change sources & upgrading packages
	cmd debconf-set-selections <<< 'openssh-server openssh-server/sshd_config multiselect /etc/ssh/sshd_config'
	Msg.info "Changing repos in $(Dye.fg.white sources.list) and upgrading packages..."
	cmd sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list /etc/apt/sources.list.d/*
	cmd apt update && cmd apt upgrade -y && cmd apt full-upgrade -y

	# change sources & upgrading packages
	Msg.info "Removing obsolete packages and cleaning up..."
	cmd apt --purge autoremove -y && cmd apt clean

	Msg.warn "Upgrade completed! Reboot to apply changes..."
}	# end Menu.distroup


Pw.mnemonic() {
	# return a psedo mnemonic password of 2 words separated by a dash
	local f p w u="https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt"
	w=$(cmd curl -s "$u" | cmd awk 'length($2) > 3 && length($2) < 7 { print $2 }')
	# save a password that have at least 3 substitutions to do
	while :; do
		p=$(cmd shuf -n2 <<< "$w" | cmd paste -sd-)
		[[ $(cmd tr -cd 'lzeasbtbg' <<< "$p" | cmd wc -c) -gt 2 ]] && break
	done
	# substitute "lzeasbtbg" with "123456789", then return the password
	echo "${p^}" | cmd perl -pe '@m=/([lzeasbtbg])/g; s/$m[-2]/index("lzeasbtbg",$m[-2]) + 1/e'
}	# end Pw.mnemonic
