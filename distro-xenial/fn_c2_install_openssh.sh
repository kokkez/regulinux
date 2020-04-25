# ------------------------------------------------------------------------------
# configure SSH server & firewall
# ------------------------------------------------------------------------------

install_openssh() {
	# $1: port - strictly in numerical range
	local PRT=$(port_validate ${1})

	# configure SSH server arguments
	sed -ri /etc/ssh/sshd_config \
		-e "s|^#?Port.*|Port ${PRT}|" \
		-e 's|^#?(PasswordAuthentication).*|\1 no|' \
		-e 's|^#?(PermitRootLogin).*|\1 without-password|' \
		-e 's|^#?(RSAAuthentication).*|\1 yes|' \
		-e 's|^#?(PubkeyAuthentication).*|\1 yes|'

	# mitigating ssh hang on reboot on systemd capables OSes
	[ -s /etc/systemd/system/ssh-user-sessions.service ] || {
		msg_info "Mitigating the SSH hang on reboot's problem"
		copy_to /etc/systemd/system ssh/ssh-user-sessions.service
		cmd systemctl enable ssh-user-sessions.service
		cmd systemctl daemon-reload
		cmd systemctl start ssh-user-sessions.service
	}

	# fix a systemd bug of xenial 16.04
	# https://askubuntu.com/questions/1109934/ssh-server-stops-working-after-reboot-caused-by-missing-var-run-sshd
	msg_info "Fixing a little systemd bug that prevent SSHd to start"
	sed -i 's|/var||' /usr/lib/tmpfiles.d/sshd.conf

	# activate on firewall & restart SSH
	firewall_allow "${PRT}"
	svc_evoke ssh restart
	msg_info "The SSH server is listening on port: ${PRT}"
}	# end install_openssh
