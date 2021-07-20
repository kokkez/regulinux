# ------------------------------------------------------------------------------
# install mailserver
# ------------------------------------------------------------------------------

Menu.mailserver() {
	# $1: target system to build, optional
	TARGET="${1:-$TARGET}"

	# abort if "Menu.deps" was not executed
	Deps.performed || return

	# postfix is valid for all TARGETs
	install_postfix

	if [ "$TARGET" = "ispconfig" ]; then
		config_postfix_ispconfig	# postfix with dovecot for ispconfig
		install_dovecot

	elif [ "$TARGET" = "assp" ]; then
		User.vmail.set
		config_postfix_assp			# configure for assp
		config_postfix_sasl2_sql
	fi;
}	# end Menu.mailserver
