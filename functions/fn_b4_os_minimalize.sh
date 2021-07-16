# ------------------------------------------------------------------------------
# customize OS minimalizing the installed packages
# ------------------------------------------------------------------------------

OS.minimalize() {
	# always use --no-install-recommends (also used as a check in "done_deps")
	cat > /etc/apt/apt.conf.d/99norecommend <<EOF
APT::Install-Recommends "0";
APT::Install-Suggests "0";
EOF

	# preseed libc6 & postfix via debconf-set-selections
	cmd debconf-set-selections <<EOF
libc6 libraries/restart-without-asking boolean true
libc6:amd64 libraries/restart-without-asking boolean true
postfix postfix/main_mailer_type select Internet Site
postfix postfix/mailname string $MAIL_NAME
postfix postfix/destinations string $HOST_FQDN,localhost
EOF

	# purging foreign architectures (i*86, ...)
	local x
	for x in $(cmd dpkg --print-foreign-architectures); do
		apt-get purge -qqy ".*:$x"
		dpkg --remove-architecture $x
		Msg.info "Purging architecture '$x' completed"
	done;

	cd /tmp
	Pkg.update	# update packages lists

	# merge infos on availabes packages
	cmd apt-cache dumpavail | cmd dpkg --merge-avail	# from jessie onward
	rm -rf /var/lib/dpkg/*-old

	# feed packages with priority: required, important
	cmd dpkg --clear-selections
	dpkg-query -Wf '${Package} ${Priority}\n' | awk '$2~/ed$|nt$/{print $1,"install"}' | dpkg --set-selections
	# on full virtualization we need to keep kernel and grub
	dpkg-query -Wf '${Package} ${Priority}\n' | awk '$1~/^grub|^initram|^linux/{print $1,"install"}' | dpkg --set-selections

	# set to install some custom packages
	x=$( File.path pkgs.custom.txt )
	[ -s "$x" ] && dpkg --set-selections < "$x"

	# set to purge packages where status != install
	dpkg --get-selections | awk '$2!~/^in/{print $1,"purge"}' | dpkg --set-selections

	# fix dependencies: loop until no more dependencies were founds
	x="-suf -o Debug::pkgDepCache::AutoInstall=1 -o Debug::pkgProblemResolver=1"
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
	apt-get -qy dist-upgrade	# ends performing dist-upgrade
	dpkg --get-selections > ~/selections.txt
}	# end OS.minimalize
