#!/bin/bash
# ==============================================================================

#	VARIABLES
#	global variables
#	----------------------------------------------------------------------------
	ENV_dir=$( cd "${BASH_SOURCE[0]%/*}" && pwd )
	. "${ENV_dir}/lib.sh"
	ENV.init

#	FUNCTIONS
#	companion functions
#	----------------------------------------------------------------------------
	File.path() {
		echo $ENV_distro
		# return the full path to a file in "files-common", looking first
		# into distro-xxx/files
		# return an empty string if nothing is found
		# $1 relative path to search
		Arg.expect "$1" || return
		cmd readlink -e "$ENV_distro/files/$1" \
			|| cmd readlink -e "$ENV_files/$1" \
			|| return 1
	}	# end File.path

	File.paths() {
		Arg.expect "$1" || return
		local f=$( cmd find $ENV_distro/files -wholename "*$1" )
		[ -z "$f" ] && f=$( cmd find $ENV_files -wholename "*$1" )
		echo "$f"
	}	# end File.paths

	File.to() {
		# copy to the destination folder in $1, the files from ${@:2}
		# that can comes exclusively from one of the "files-common" folders
		Arg.expect "$1" "$2" || return

		local a f d=$( cmd readlink -e $1 )
		[ -d "$d" ] || return
		echo "$d"

		for a in "${@:2}"					# iterating from 2nd arguments
		do
			for f in $( File.paths "$a" )	# iterating files
			do
				#File.recopy "$f" "$d/$( cmd basename $f )"
				#echo "Copy in $d the file $( cmd basename $f )"
				echo "Copy in $d/${f##*/} the file $f"
			done
		done
	}	# end File.to





#	PROGRAM
#	main program to run
#	----------------------------------------------------------------------------
	File.to "$@"
	echo $?
