# ------------------------------------------------------------------------------
# cleanup OS minimizing the installed packages
# ------------------------------------------------------------------------------

OS.minimalize() {
	# install sources.list from MyDir
	copy_to /etc/apt sources.list
	Msg.info "Installed /etc/apt/sources.list for ${OS} (${DISTRO})..."

	# always use --no-install-recommends (also used as a check in "done_deps")
	cat > /etc/apt/apt.conf.d/99norecommend <<EOF
APT::Install-Recommends "0";
APT::Install-Suggests "0";
EOF

	# preseed libc6 & postfix via debconf-set-selections
	debconf-set-selections <<EOF
libc6 libraries/restart-without-asking boolean true
libc6:amd64 libraries/restart-without-asking boolean true
postfix postfix/main_mailer_type select Internet Site
postfix postfix/mailname string ${MAIL_NAME}
postfix postfix/destinations string ${HOST_FQDN}, localhost
EOF

	# purging foreign architectures (i*86, ...)
	local i x
	for x in $(cmd dpkg --print-foreign-architectures); do
		apt-get purge -qqy ".*:${x}"
		dpkg --remove-architecture ${x}
		Msg.info "Architecture '${x}' removed"
	done;

	cd /tmp
	pkg_update	# update packages lists

	# merge infos on availabes packages
	cmd apt-cache dumpavail | cmd dpkg --merge-avail	# from jessie onward
	rm -rf /var/lib/dpkg/*-old

	# feed packages with priority: required, important
	cmd dpkg --clear-selections
	dpkg-query -Wf '${Package} ${Priority}\n' | awk '$2~/ed$|nt$/{print $1,"install"}' | dpkg --set-selections
	# on full virtualization we need to keep kernel and grub
	dpkg-query -Wf '${Package} ${Priority}\n' | awk '$1~/^grub|^initram|^linux/{print $1,"install"}' | dpkg --set-selections

	# set to purge packages where status != install
	dpkg --get-selections | awk '$2!~/^in/{print $1,"purge"}' | dpkg --set-selections

	# set to install some custom packages
	x="${MyDISTRO}/pkgs.custom.txt"
	[ -s ${x} ] && dpkg --set-selections < ${x}

	# fix dependencies: loop until no more dependencies were founds
	x="-suf -o Debug::pkgDepCache::AutoInstall=1 -o Debug::pkgProblemResolver=1"
	while true; do
		apt-get ${x} dselect-upgrade 2> pkgs.log.txt 1>/dev/null
		# --simulate --show-upgraded --fix-broken
		awk '/as (Pre)?Depends of/{print $2}' pkgs.log.txt > pkgs.adds.txt
		awk '/^Broken .+ (Pre)?Depends on /{print $5}' pkgs.log.txt >> pkgs.adds.txt
		[ -s pkgs.adds.txt ] || break
		cmp -s pkgs.adds.txt pkgs.copy.txt && break
		cat pkgs.adds.txt > pkgs.copy.txt
		sort -u pkgs.adds.txt | awk -F: '{print $1,"install"}' | dpkg --set-selections
	done;

	# do the real dselect-upgrade
	export DEBIAN_FRONTEND=noninteractive
	apt-get -ufy -o Dpkg::Options::="--force-confnew" dselect-upgrade
	rm -rf pkg*.txt				# removing temp files
	apt-get -qy dist-upgrade	# ends performing dist-upgrade
	dpkg --get-selections > ~/selections.txt
}	# end OS.minimalize
