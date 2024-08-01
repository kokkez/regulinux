# ------------------------------------------------------------------------------
# custom functions specific to debian 11 bullseye
# ------------------------------------------------------------------------------

Menu.upgrade() {
	Msg.info "Upgrading system packages for ${ENV_os}..."
	Pkg.update	# update packages lists

	# do the apt upgrade
	export DEBIAN_FRONTEND=noninteractive
	cmd apt -qy full-upgrade
}	# end Menu.upgrade


Menu.inet() {
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
		ip6*)   v=$( Menu.inet cidr6 ); v="${v%%/*}" ;;
		ip*)    v=$( Menu.inet cidr ); v="${v%%/*}" ;;
		*)      v=$( cmd ip r get 1 | cmd grep -oP 'dev \K\S+' ) ;;
	esac
	echo "$v";
}	# Menu.inet


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
