#!/bin/bash
# ==============================================================================
# setup script for install Linux OSes, only Debian like for now...
# started by kokkez on 2018-01
# ==============================================================================

#	import main library
#	----------------------------------------------------------------------------
	# $0 refers to the calling script
	# ${BASH_SOURCE[0]} refers to this particular file
	ENV_dir=$( cd "${BASH_SOURCE[0]%/*}" && pwd )
	. "${ENV_dir}/lib.sh"


#	main program
#	----------------------------------------------------------------------------
	# on exit and CTRL C execute some cleanup
	trap Env.clean EXIT

	PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
	export PATH=${PATH}

	# environment initialization
	ENV.init

	# check for not empty argument and available command, then exec it
	if [ -n "$1" ] && is_available "menu_${1}"; then
		cmd "menu_$1" "${@:2}"
		Msg.debug "Execution of '${1}' completed!"
	else
		OS.menu
	fi;
