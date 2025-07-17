# ------------------------------------------------------------------------------
# customize the OS, minimalizing the installed packages
# ------------------------------------------------------------------------------

OS.minimalize.gpt() {
	# always use --no-install-recommends (also used as a check in "Deps.performed")
	cat > /etc/apt/apt.conf.d/99norecommend <<- EOF
		APT::Install-Recommends "0";
		APT::Install-Suggests "0";
		EOF

	# avoid interactive prompts preseeding libc6 & postfix via debconf-set-selections
	debconf-set-selections <<- EOF
		libc6 libraries/restart-without-asking boolean true
		libc6:amd64 libraries/restart-without-asking boolean true
		postfix postfix/main_mailer_type select Internet Site
		postfix postfix/mailname string $MAIL_NAME
		postfix postfix/destinations string $HOST_FQDN,localhost
		EOF

	# purge foreign architectures (i*86, etc) fully, removing arch from dpkg
	local x
	for x in $(dpkg --print-foreign-architectures); do
		apt-get purge -qqy ".*:$x"					# purge packages of foreign arch
		dpkg --remove-architecture $x				# remove architecture from dpkg
		Msg.info "Purging architecture '$x' completed"
	done;

	cd /tmp
	Pkg.update	# update apt package lists

	# merge available packages info, fixes metadata after update
	apt-cache dumpavail | dpkg --merge-avail
	[ -d /var/lib/dpkg ] && rm -rf /var/lib/dpkg/*-old	# clean old dpkg metadata files

	# reset dpkg selections: clear all first
	dpkg --clear-selections

	# set required and important packages to install (base system essentials)
	dpkg-query -Wf '${Package} ${Priority}\n' | awk '$2~/ed$|nt$/{print $1,"install"}' | dpkg --set-selections

	# on full virtualization keep kernel, initramfs and grub packages
	dpkg-query -Wf '${Package} ${Priority}\n' | awk '$1~/^grub|^initram|^linux/{print $1,"install"}' | dpkg --set-selections

	# add custom packages from file (custom minimal needed packages)
	x=$( File.path pkgs.custom.txt )
	[ -s "$x" ] && dpkg --set-selections < "$x"

	# purge all packages not marked as install to remove leftovers and unwanted pkgs
	dpkg --get-selections | awk '$2!~/^in/{print $1,"purge"}' | dpkg --set-selections

	# loop to fix broken dependencies and auto-install needed packages
	x="-suf -o Debug::pkgDepCache::AutoInstall=1 -o Debug::pkgProblemResolver=1"
	while true; do
		apt-get $x dselect-upgrade 2> pkgs.log.txt 1>/dev/null

		# parse broken dependencies from log to install missing packages
		awk '/^Broken .+Depends on /{print $5}' pkgs.log.txt > pkgs.adds.txt

		# exit loop if no new dependencies found or same as previous iteration
		[ -s pkgs.adds.txt ] || break
		cmp -s pkgs.adds.txt pkgs.copy.txt && break

		cat pkgs.adds.txt > pkgs.copy.txt
		awk -F: '{print $1,"install"}' pkgs.adds.txt | sort -u | dpkg --set-selections
	done;

	# purge orphaned packages and clean residual configs after loop
	apt-get autoremove --purge -qy

	# do the real dselect-upgrade to apply changes, force new config files
	export DEBIAN_FRONTEND=noninteractive
	apt-get -ufy -o Dpkg::Options::="--force-confnew" dselect-upgrade

	# remove temporary package files
	rm -rf pkg*.txt

	# final dist-upgrade to ensure system fully up to date
	apt-get -qy dist-upgrade

	# back to home and save current dpkg selections snapshot
	cd ~
	dpkg --get-selections > ~/selections.txt
}	# end OS.minimalize
