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
