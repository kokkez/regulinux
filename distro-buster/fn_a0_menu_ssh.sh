# ------------------------------------------------------------------------------
# setup authorized_keys, then configure bash & SSH server
# ------------------------------------------------------------------------------

setup_private_keys() {
	mkdir -p ~/.ssh && cd "$_"
	cmd chmod 0700 ~/.ssh
	cmd chmod 0600 authorized_keys
	msg_info "Setup of authorized_keys completed!"
}	# end setup_private_keys


setup_bash() {
	# set bash as the default shell
	debconf-set-selections <<< "dash dash/sh boolean false"
	dpkg-reconfigure -f noninteractive dash
	[ -f ~/.bashrc ] || copy_to ~ .bashrc
	msg_info "Switching default shell to BASH completed!"
}	# end setup_bash


setup_openssh() {
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
		msg_info "Mitigating the problem of SSH hangs on reboot"
		cp /usr/share/doc/openssh-client/examples/${X} /etc/systemd/system/
		cmd systemctl daemon-reload
		cmd systemctl enable ${X}
		cmd systemctl start ${X}
		# edit script to catch all sshd demons: shell & winscp
		sed -ri /usr/lib/openssh/ssh-session-cleanup \
			-e 's|^(ssh_session_pattern).*|\1="sshd: \\\S.*@\\\w+"|'
	}

	# restart SSH server
	cmd systemctl restart ssh
	msg_info "The SSH server is now listening on port: ${P}"
}	# end setup_openssh


menu_ssh() {
	# sanity check, stop here if my key is missing
	grep -q "kokkez" ~/.ssh/authorized_keys || {
		msg_error "Missing 'kokkez' private key in '~/.ssh/authorized_keys'"
	}

	setup_private_keys
	setup_bash

	# copy preferences for htop
	[ -d ~/.config/htop ] || {
		mkdir -p ~/.config/htop && cd "$_"
		copy_to . htop/*
		cmd chmod 0700 ~/.config ~/.config/htop
	}

	setup_openssh "${1:-${SSHD_PORT}}"
}	# end menu_ssh
