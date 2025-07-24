# ------------------------------------------------------------------------------
# customize the OS, minimalizing the installed packages
# ------------------------------------------------------------------------------

Min.prepare() {
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
	local a
	for a in $(dpkg --print-foreign-architectures); do
		apt-get purge -qqy ".*:$a"			# purge packages of foreign arch
		dpkg --remove-architecture "$a"		# remove architecture from dpkg
		Msg.info "Purged architecture '$a' completed"
	done;
}	# end Min.prepare


Min.reset() {
	Pkg.update	# update packages lists

	# merge infos on availabes packages
	apt-cache dumpavail | dpkg --merge-avail			# from jessie onward
	[ -d /var/lib/dpkg ] && rm -rf /var/lib/dpkg/*-old	# clean old dpkg metadata files

	# feed packages with priority: required, important
	dpkg --clear-selections
	dpkg-query -Wf '${Package} ${Priority}\n' | awk '$2~/ed$|nt$/{print $1,"install"}' | dpkg --set-selections
	# on full virtualization keep kernel, initramfs and grub packages
	dpkg-query -Wf '${Package} ${Priority}\n' | awk '$1~/^grub|^initram|^linux/{print $1,"install"}' | dpkg --set-selections

	# add custom packages from file (custom minimal needed packages)
	local p=$( File.path pkgs.custom.txt )
	[ -s "$p" ] && dpkg --set-selections < "$p"

	# purge all packages marked as deinstall or purge
	dpkg --get-selections | awk '$2 ~ /e/ {print $1,"purge"}' | dpkg --set-selections
}	# end Min.reset


Min.loop() {
	cd /tmp
	# fix dependencies: loop until no more dependencies were founds
	x='-suf -o Debug::pkgDepCache::AutoInstall=1 -o Debug::pkgProblemResolver=1'
	while true; do
		apt-get $x dselect-upgrade 2> pkgs.log.txt 1>/dev/null
		# --simulate --show-upgraded --fix-broken
#		awk '/ as.+Depends of /{print $2}' pkgs.log.txt > pkgs.adds.txt
		awk '/^Broken .+Depends on /{print $5}' pkgs.log.txt > pkgs.adds.txt
#		awk '/ via keep of | rather than change /{print $NF}' pkgs.log.txt >> pkgs.adds.txt
		[ -s pkgs.adds.txt ] || break
		cmp -s pkgs.adds.txt pkgs.copy.txt && break
		cat pkgs.adds.txt > pkgs.copy.txt
		awk -F: '{print $1,"install"}' pkgs.adds.txt | sort -u | dpkg --set-selections
	done;

	# do the real dselect-upgrade
	export DEBIAN_FRONTEND=noninteractive
	apt-get -ufy -o Dpkg::Options::="--force-confnew" dselect-upgrade
	rm -rf pkg*.txt				# removing temp files
	cd ~
}	# end Min.loop


Min.finishing() {
	# this fn is particular for ubuntu 22 jammy
	Msg.info "Finalizing minimize procedure for $ENV_os $ENV_arch"

	# re purge hards to die
	apt purge mailcap media-types mime-support
	# re install wrongly purged
	#apt install curl htop rsync screen telnet

	apt-get -qy dist-upgrade	# ends performing dist-upgrade
	apt autoremove
	dpkg --get-selections > ~/selections.txt
}	# end Min.finishing


OS.minimalize() {
	Msg.info "Minimizing $ENV_os $ENV_arch"

	# prepare & reset
	Min.prepare
	Min.reset
	# loop over entire selection
	Min.loop

	# finishing
	Min.finishing
}	# end OS.minimalize
