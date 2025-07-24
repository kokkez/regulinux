#!/usr/bin/env bash
#
# this is a Message of the Day (MOTD) replacement. It will display its
# information only after the login process has completed, eliminating
# access issues for automated systems that do not benefit from these
# calculations, such as backup systems, as well as SSH accesses without
# a terminal, such as WinSCP
#
# Copyleft (c) 2024 Luigi Cocconcelli

# stop here if ! interactive, or ! in a terminal or if "~/.hushlogin" exists
[[ $- == *i* && -t 1 && ! -f ~/.hushlogin ]] && {
	bash $(find ~/r* -name os.* -print -quit) motd show
}
