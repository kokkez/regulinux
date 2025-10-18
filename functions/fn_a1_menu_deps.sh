# ------------------------------------------------------------------------------
# arrange the system preparing a basic OS, ready to host applications
# it will setup:
#  - authorized keys
#  - apt/sources.list
#  - bash as default shell
#  - setup /etc/network/interfaces file
#  - customize resolv.conf with public dns
#  - customize timezone & localtime
#  - minimalizing the installed packages
#  - customize the "Mot Of The Day" screen
#  - simple vanilla syslogd to replace rsyslogd
#  - mitigation of "ssh hang on reboot"
#  - strong configuration of SSHd
#  - customized .bashrc
#  - customized preferences for htop
# ------------------------------------------------------------------------------

Arrange.authkeys() {
	# set authorized_keys to allow comfortable root logins
	local p="$HOME/.ssh/authorized_keys"

	# stop here if no public keys found
	[ -s "$p" ] || {
		Msg.error "The required file '$p' is missing"
	}
	[[ $(< "$p") =~ (ssh-(rsa|ed25519)|ecdsa-sha2) ]] || {
		Msg.error "No valid SSH keys found in '$p'"
	}

	# set correct permissions to ~/.ssh/ & authorized_keys
	mkdir -p "${p%/*}"
	chmod 0700 "${p%/*}"
	chmod 0600 "$p"
	Msg.info "Setup of authorized_keys completed!"
}	# end Arrange.authkeys


Arrange.sources() {
	# install sources.list for apt
	File.into /etc/apt sources.list
	Msg.info "Installation of 'sources.list' for $ENV_os completed!"
}	# end Arrange.sources


Arrange.shell() {
	# set bash as the default shell
	cmd debconf-set-selections <<< 'dash dash/sh boolean false'
	cmd dpkg-reconfigure -f 'noninteractive' 'dash'
	Msg.info "Switch to BASH as default shell completed!"
}	# end Arrange.shell


Arrange.unhang() {
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
}	# end Arrange.unhang


Arrange.sshd() {
	# configure SSH server parameters
	# $1: ssh port number, optional
	SSHD_PORT=$( Port.audit ${1:-$SSHD_PORT} )
	cmd sed -ri "$ENV_dir/lib.sh" \
		-e "s|^(\s*SSHD_PORT=).*|\1'$SSHD_PORT'|"
	cmd sed -ri /etc/ssh/sshd_config \
		-e "s|^#?(Port)\s.*|\1 $SSHD_PORT|" \
		-e 's|^#?(PasswordAuthentication)\s.*|\1 no|' \
		-e 's|^#?(PermitRootLogin)\s.*|\1 without-password|' \
		-e 's|^#?(RSAAuthentication)\s.*|\1 yes|' \
		-e 's|^#?(PubkeyAuthentication)\s.*|\1 yes|'
	cmd systemctl restart ssh
	Msg.info "SSH server is now listening on port: $SSHD_PORT"
}	# end Arrange.sshd


Arrange.bashrc() {
	# copy our customized version of .bashrc in home folder
	local p=~/.bashrc
	[ -s "$p" ] && grep -q 'os\.sh' "$p" || {
		File.into ~ .bashrc
		Msg.info "Switch to a customized '~/.bashrc' completed!"
	}
	source "$p"
}	# end Arrange.bashrc


Arrange.htop() {
	# copy preferences for htop
	local p=~/.config/htop
	[ -d "$p" ] || {
		mkdir -p "$p"
		File.into "$p" htop/*
		cmd chmod 0700 "${p%/*}" "$p"
		Msg.info "Installation of preferences for htop completed!"
	}
}	# end Arrange.htop


Deps.performed() {
	# return success if the step "Menu.deps" was already performed
	# simply check that 99norecommend exists into apt.conf.d
	[ -f '/etc/apt/apt.conf.d/99norecommend' ] && return 0
	# simply check that /etc/apt/apt.conf.d/99norecommend exists
	Msg.warn "Need to execute the step '$(Dye.fg.white os deps)' before..."
	return 1
}	# end Deps.performed


Menu.deps() {
	# metadata for OS.menu entries
	__section="One time actions"
	__summary="check dependencies, update the base system, setup firewall"

	# preparing a basic OS, ready to host applications
	# $1: ssh port number, optional

	# feedback user if called with port number
	[ -n "$1" ] && {
		Msg.info "SSH server will listen on port: $1"
	}

	Arrange.authkeys		# stop here if no private keys found
	Arrange.sources			# install sources.list for apt
	Arrange.shell			# set bash as the default shell

	OS.networking			# setup /etc/network/interfaces file
	OS.resolvconf			# customize resolv.conf with public dns
	OS.timedate				# customize timezone & localtime

	OS.minimalize			# minimalizing the installed packages
	Install.motd			# customize the "Mot Of The Day" screen
	Install.syslogd			# simple vanilla syslogd to replace rsyslogd

	Arrange.unhang			# mitigating ssh hang on reboot, via systemd
	Arrange.sshd "$1"		# configure SSH server parameters
	Install.firewall "$1"	# activating firewall, allowing SSH logins

	Arrange.bashrc			# customize .bashrc in home folder
	Arrange.htop			# customize preferences for htop
}	# end Menu.deps


Menu.root() {
	# metadata for OS.menu entries
	__section="One time actions"
	__summary="setup private key, sources.list, shell, SSH on port $(Dye.fg.white $SSHD_PORT)"

	# arrange the OS to comfortably accept root logins
	# $1: ssh port number, optional

	Arrange.authkeys		# stop here if no private keys found
	Arrange.sources			# install sources.list for apt
	Arrange.shell			# set bash as the default shell

	Arrange.unhang			# mitigating ssh hang on reboot, via systemd
	Arrange.sshd "$1"		# configure SSH server parameters
	Install.firewall "$1"	# activating firewall, allowing SSH logins

	Arrange.bashrc			# customize .bashrc in home folder
	Arrange.htop			# customize preferences for htop
}	# end Menu.root
