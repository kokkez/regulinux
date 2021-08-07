# ------------------------------------------------------------------------------
# arrange the system for the root user, setting up:
#  - authorized keys
#  - apt/sources.list
#  - bash as default shell
#  - customized .bashrc
#  - strong configuration of SSHd
#  - mitigation of "ssh hang on reboot"
# ------------------------------------------------------------------------------

SSH.antihangs() {
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
}	# end SSH.antihangs


Menu.root() {
	# arrange the system for the root user
	# $1 - ssh port number, optional

	# stop here if no private key was found
	local p=~/.ssh
	grep -q '^ssh\-rsa' "$p/authorized_keys" || {
		Msg.error "Missing 'ssh-rsa' private key in '$p/authorized_keys'"
	}

	# set correct permissions to .ssh/ & authorized_keys
	mkdir -p "$p"
	cmd chmod 0700 "$p"
	cmd chmod 0600 "$p/authorized_keys"
	Msg.info "Setup of authorized_keys completed!"

	# install sources.list for apt
	File.into /etc/apt sources.list
	Msg.info "Installation of 'sources.list' for $ENV_os completed!"

	# set bash as the default shell
	cmd debconf-set-selections <<< 'dash dash/sh boolean false'
	cmd dpkg-reconfigure -f 'noninteractive' 'dash'
	Msg.info "Switch to BASH as default shell completed!"

	SSH.antihangs

	# configure SSH server parameters
	p=$( Port.audit ${1:-$SSHD_PORT} )
	cmd sed -ri /etc/ssh/sshd_config \
		-e "s|^#?(Port)\s.*|\1 $p|" \
		-e 's|^#?(PasswordAuthentication)\s.*|\1 no|' \
		-e 's|^#?(PermitRootLogin)\s.*|\1 without-password|' \
		-e 's|^#?(RSAAuthentication)\s.*|\1 yes|' \
		-e 's|^#?(PubkeyAuthentication)\s.*|\1 yes|'
	cmd systemctl restart ssh
	Msg.info "SSH server is now listening on port: $p"

	# copy our customized version of .bashrc in home folder
	p=~/.bashrc
	[ -s "$p" ] && grep -q 'os\.sh' "$p" || {
		File.into ~ .bashrc
		source "$p"
		Msg.info "Switch to a customized '~/.bashrc' completed!"
	}

	# copy preferences for htop
	p=~/.config/htop
	[ -d "$p" ] || {
		mkdir -p "$p"
		File.into "$p" htop/*
		cmd chmod 0700 "${p%/*}" "$p"
		Msg.info "Installation of preferences for htop completed!"
	}
};	# end Menu.root
