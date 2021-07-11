# ------------------------------------------------------------------------------
# configure SSH server & firewall
# ------------------------------------------------------------------------------

install_openssh() {
	# $1: port - strictly in numerical range
	local x p=$( Port.audit $1 )

	# configure SSH server arguments
	sed -ri /etc/ssh/sshd_config \
		-e "s|^#?Port.*|Port $p|" \
		-e 's|^#?(PasswordAuthentication).*|\1 no|' \
		-e 's|^#?(PermitRootLogin).*|\1 without-password|' \
		-e 's|^#?(RSAAuthentication).*|\1 yes|' \
		-e 's|^#?(PubkeyAuthentication).*|\1 yes|'

	# mitigating ssh hang on reboot on systemd capables OSes
	x=ssh-user-sessions.service
	[ -s /etc/systemd/system/$x ] || {
		Msg.info "Mitigating the SSH hang on reboot's problem"
		File.into /etc/systemd/system ssh/$x
		cmd systemctl enable $x
		cmd systemctl daemon-reload
		cmd systemctl start $x
	}

	# activate on firewall & restart SSH
	firewall_allow "$p"
	svc_evoke ssh restart
	Msg.info "The SSH server is listening on port: $p"
}	# end install_openssh
