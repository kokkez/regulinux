#!/bin/bash
################################################################################
# OpenVZ VPS setup script for installing Debian like OSes
# by kokkez on 2018-01
################################################################################

# ==============================================================================
#                                                           import main library
# ==============================================================================

	MyDir=$(cd $(command dirname "$0"); pwd)
	. ${MyDir}/lib.sh


# ==============================================================================
#                                                                  main program
# ==============================================================================

	# on exit and CTRL C execute some cleanup
	trap clean_up EXIT

	PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
	export PATH=${PATH}

	# get info on system
	detect_linux

	if [ -n "${1}" ] && is_available "menu_${1}"; then
		cmd "menu_${1}" "${@:2}"
		msg_notice "Execution of '${1}' completed!"
	else
		help_menu
	fi;
