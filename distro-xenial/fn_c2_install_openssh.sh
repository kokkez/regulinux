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
	X=ssh-user-sessions.service
	[ -s /etc/systemd/system/${X} ] || {
		Msg.info "Mitigating the problem of SSH hangs on reboot"
		copy_to /etc/systemd/system ssh/${X}
		cmd systemctl daemon-reload
		cmd systemctl enable ${X}
		cmd systemctl start ${X}
	}

	# fix a systemd bug of xenial 16.04
	# https://askubuntu.com/questions/1109934/ssh-server-stops-working-after-reboot-caused-by-missing-var-run-sshd
	X=/usr/lib/tmpfiles.d/sshd.conf
	grep -q '/var' ${X} && {
		Msg.info "Fixing a little systemd bug that prevent SSHd to start"
		sed -i 's|/var||' ${X}
#		cmd mkdir -p -m0755 /var/run/sshd
	}

	# activate on firewall & restart SSH
	firewall_allow "${P}"
	svc_evoke ssh restart
	Msg.info "The SSH server is listening on port: ${P}"
}	# end install_openssh
