# ------------------------------------------------------------------------------
# configure SSH server & firewall
# ------------------------------------------------------------------------------

install_openssh() {
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
#	X=ssh-user-sessions.service
	[ -s /etc/systemd/system/${X} ] || {
		msg_info "Mitigating the problem of SSH hangs on reboot"
		cp /usr/share/doc/openssh-client/examples/${X} /etc/systemd/system/
#		copy_to /etc/systemd/system ssh/${X}
		cmd systemctl daemon-reload
		cmd systemctl enable ${X}
		cmd systemctl start ${X}
		# edit script to catch all sshd demons: shell & winscp
		sed -ri /usr/lib/openssh/ssh-session-cleanup \
			-e 's|^(ssh_session_pattern).*|\1="sshd: \\\S.*@\\\w+"|'
	}

	# activate on firewall & restart SSH
	firewall_allow "${P}"
	svc_evoke ssh restart
	msg_info "The SSH server is listening on port: ${P}"
}	# end install_openssh
