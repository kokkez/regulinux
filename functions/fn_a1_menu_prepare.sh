# ------------------------------------------------------------------------------
# arrange the system preparing a basic OS, ready to host applications
# it will setup:
#  - authorized keys
#  - apt/sources.list
#  - bash as default shell
#  - mitigation of "ssh hang on reboot"
#  - strong configuration of SSHd
#  - customized .bashrc
#  - customized preferences for htop
# ------------------------------------------------------------------------------

Prepare.authkeys() {
	# set authorized_keys to allow comfortable root logins
	local p=~/.ssh

	# stop here if no private keys found
	[ -s "$p/authorized_keys" ] || {
		Msg.error "The required file '$p/authorized_keys' is missing"
	}
	grep -q '^ssh\-rsa' "$p/authorized_keys" || {
		Msg.error "Missing 'ssh-rsa' private key in '$p/authorized_keys'"
	}

	# set correct permissions to .ssh/ & authorized_keys
	mkdir -p "$p"
	cmd chmod 0700 "$p"
	cmd chmod 0600 "$p/authorized_keys"
	Msg.info "Setup of authorized_keys completed!"
}	# end Prepare.authkeys


Prepare.sources() {
	# install sources.list for apt
	File.into /etc/apt sources.list
	Msg.info "Installation of 'sources.list' for $ENV_os completed!"
}	# end Prepare.sources


Prepare.shell() {
	# set bash as the default shell
	cmd debconf-set-selections <<< 'dash dash/sh boolean false'
	cmd dpkg-reconfigure -f 'noninteractive' 'dash'
	Msg.info "Switch to BASH as default shell completed!"
}	# end Prepare.shell


Prepare.antihangs() {
	# mitigating ssh hang on reboot on systemd capables OSes
	# no arguments expected
	local p f='ssh-session-cleanup.service'

	# install & enable a file already present in the OS
	[ -s "/etc/systemd/system/$f" ] || {
		p="/usr/share/doc/openssh-client/examples/$f"
		[ -s "$p" ] && {
			cmd cp "$p" '/etc/systemd/system/'
			cmd systemctl enable "$f"
			cmd systemctl start "$f"
			cmd systemctl daemon-reload
		}
	}

	# edit script to catch all sshd demons: shell & winscp
	p='/usr/lib/openssh/ssh-session-cleanup'
	[ -s "$p" ] && {
		sed -ri "$p" \
			-e 's|^(ssh_session_pattern=).*|\1"sshd: \\\S.*@\\\w+"|'
		Msg.info "Mitigation of 'SSH hangs on reboot' completed"
	}
}	# end Prepare.antihangs


Prepare.sshd() {
	# configure SSH server parameters
	# $1: ssh port number, optional
	p=$( Port.audit ${1:-$SSHD_PORT} )
	cmd sed -ri /etc/ssh/sshd_config \
		-e "s|^#?(Port)\s.*|\1 $p|" \
		-e 's|^#?(PasswordAuthentication)\s.*|\1 no|' \
		-e 's|^#?(PermitRootLogin)\s.*|\1 without-password|' \
		-e 's|^#?(RSAAuthentication)\s.*|\1 yes|' \
		-e 's|^#?(PubkeyAuthentication)\s.*|\1 yes|'
	cmd systemctl restart ssh
	Msg.info "SSH server is now listening on port: $p"
}	# end Prepare.sshd


Prepare.bashrc() {
	# copy our customized version of .bashrc in home folder
	local p=~/.bashrc
	[ -s "$p" ] && grep -q 'os\.sh' "$p" || {
		File.into ~ .bashrc
		source "$p"
		Msg.info "Switch to a customized '~/.bashrc' completed!"
	}
}	# end Prepare.bashrc


Prepare.htop() {
	# copy preferences for htop
	local p=~/.config/htop
	[ -d "$p" ] || {
		mkdir -p "$p"
		File.into "$p" htop/*
		cmd chmod 0700 "${p%/*}" "$p"
		Msg.info "Installation of preferences for htop completed!"
	}
}	# end Prepare.htop


Menu.prepare() {
	# preparing a basic OS, ready to host applications
	# $1: ssh port number, optional

	Prepare.authkeys		# stop here if no private keys found
	Prepare.sources			# install sources.list for apt
	Prepare.shell			# set bash as the default shell

	OS.networking			# setup /etc/network/interfaces file
	OS.resolvconf			# customize resolv.conf with public dns
	OS.timedate				# customize timezone & localtime
	OS.minimalize			# minimalizing the installed packages

	Install.motd			# customize the "Mot Of The Day" screen
	Install.syslogd			# simple vanilla syslogd to replace rsyslogd

	Prepare.antihangs		# mitigating ssh hang on reboot, via systemd
	Prepare.sshd "$1"		# configure SSH server parameters
	Install.firewall "$1"	# activating firewall, allowing SSH port

	Prepare.bashrc			# customize .bashrc in home folder
	Prepare.htop			# customize preferences for htop
}	# end Menu.prepare
