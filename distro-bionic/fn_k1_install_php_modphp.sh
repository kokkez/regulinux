# ------------------------------------------------------------------------------
# install PHP as MOD-PHP alone
# ------------------------------------------------------------------------------

install_php_modphp() {
	# abort if package was already installed
	is_installed "libapache2-mod-php" && {
		msg_alert "PHP as MOD-PHP is already installed..."
		return
	}

	# add external repository for updated php 7.3
#	is_installed "software-properties-common" || {
#		msg_info "Installing required packages..."
#		pkg_install python-software-properties software-properties-common
#	}
#	LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php

	# forcing apt update
	pkg_update true

	# now install php packages
	pkg_install php libapache2-mod-php php-mysql php-gd

	# adjust date.timezone in all php.ini
	sed -ri "s|^;(date\.timezone =).*|\1 '${TIME_ZONE}'|" /etc/php/*/*/php.ini

	msg_info "Configuration of MOD-PHP completed!"
}	# end install_php_modphp




