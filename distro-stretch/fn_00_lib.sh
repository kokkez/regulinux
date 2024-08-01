# ------------------------------------------------------------------------------
# custom functions specific to debian 9 stretch
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
	local v
	case "$1" in
		cidr6*) v=$(cmd ip -o -6 a | cmd awk '/global/ {print $4}') ;;
		cidr*)  v=$(cmd ip -o -4 a | cmd awk '/global/ {print $4}') ;;
		gw6*)   v=$(cmd ip -6 r | cmd grep -oP 'via \K\S+') ;;
		gw*)    v=$(cmd ip -4 r | cmd grep -oP 'via \K\S+') ;;
		ip6*)   v=$(cmd ip -6 r | cmd grep -oP 'src \K\S+') ;;
		ip*)    v=$(cmd ip -4 r | cmd grep -oP 'src \K\S+') ;;
		*)      v=$(cmd ip r | cmd awk '/default/ {print $NF}') ;;
	esac
	echo "$v";
}	# Menu.inet


Arrange.sources() {
	# install sources.list for apt
	File.into /etc/apt sources.list
	# get pgpkey from freexian
	File.download \
		https://deb.freexian.com/extended-lts/archive-key.gpg \
		/etc/apt/trusted.gpg.d/freexian-archive-extended-lts.gpg
	Msg.info "Installation of 'sources.list' for $ENV_os completed!"
}	# end Arrange.sources


Repo.php() {
	# add external repository for updated php
	local p='/etc/apt/sources.list.d/php.list'
	[ -s "$p" ] && return

	# add external repository for updated php
	Pkg.requires apt-transport-https lsb-release ca-certificates
	File.download \
		https://packages.sury.org/php/apt.gpg \
		/etc/apt/trusted.gpg.d/php.gpg
	cat > "$p" <<-EOF
		# https://www.patreon.com/oerdnj
		deb http://packages.sury.org/php $ENV_codename main
		#deb-src http://packages.sury.org/php $ENV_codename main
		EOF
	# forcing apt update
	Pkg.update 'coerce'
}	# end Repo.php
