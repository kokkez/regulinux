# ------------------------------------------------------------------------------
# setup authorized_keys, then configure bash & SSH server
# ------------------------------------------------------------------------------

setup_bash() {
	# set bash as the default shell
	debconf-set-selections <<< "dash dash/sh boolean false"
	dpkg-reconfigure -f noninteractive dash
	[ -f ~/.bashrc ] || copy_to ~ .bashrc
	Msg.info "Default shell switched to BASH"
}	# end setup_bash


setup_sshd() {
	# $1: port - strictly in numerical range
	local X P=$(port_validate ${1})

	# configure SSH server arguments
	sed -ri /etc/ssh/sshd_config \
		-e "s|^#?Port.*|Port ${P}|" \
		-e 's|^#?(PasswordAuthentication).*|\1 no|' \
		-e 's|^#?(PermitRootLogin).*|\1 without-password|' \
		-e 's|^#?(RSAAuthentication).*|\1 yes|' \
		-e 's|^#?(PubkeyAuthentication).*|\1 yes|'

	# mitigating ssh hang on reboot on systemd capables OSes
	X=ssh-session-cleanup.service
	[ -s /etc/systemd/system/${X} ] || {
		cp /usr/share/doc/openssh-client/examples/${X} /etc/systemd/system/
		cmd systemctl daemon-reload
		cmd systemctl enable ${X}
		cmd systemctl start ${X}
		# edit script to catch all sshd demons: shell & winscp
		sed -ri /usr/lib/openssh/ssh-session-cleanup \
			-e 's|^(ssh_session_pattern).*|\1="sshd: \\\S.*@\\\w+"|'
		Msg.info "Mitigation of 'SSH hangs on reboot' completed"
	}

	# restart SSH server
	cmd systemctl restart ssh
	Msg.info "SSH server is now listening on port: ${P}"
}	# end setup_sshd


menu_ssh() {
	# sanity check, stop here if my key is missing
	grep -q "kokkez" ~/.ssh/authorized_keys || {
		Msg.error "Missing 'kokkez' private key in '~/.ssh/authorized_keys'"
	}
	mkdir -p ~/.ssh && cd "$_"
	cmd chmod 0700 ~/.ssh
	cmd chmod 0600 authorized_keys
	Msg.info "Setup of authorized_keys completed!"

	# install sources.list from MyDir
	copy_to /etc/apt sources.list
	Msg.info "Installed /etc/apt/sources.list for ${OS} (${DISTRO})..."

	# copy preferences for htop
	[ -d ~/.config/htop ] || {
		mkdir -p ~/.config/htop && cd "$_"
		copy_to . htop/*
		cmd chmod 0700 ~/.config ~/.config/htop
		Msg.info "Installation of preferences for htop completed!"
	}

	setup_bash
	setup_sshd "${1:-${SSHD_PORT}}"
}	# end menu_ssh
