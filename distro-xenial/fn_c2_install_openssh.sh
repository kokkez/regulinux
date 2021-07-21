# ------------------------------------------------------------------------------
# configure SSH server & firewall
# ------------------------------------------------------------------------------

install_openssh() {
	# $1 - ssh port, numerical
	local x p=$( Port.audit ${1:-$SSHD_PORT} )

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
		Msg.info "Mitigating the problem of SSH hangs on reboot"
		File.into /etc/systemd/system ssh/$x
		cmd systemctl enable $x
		cmd systemctl start $x
		cmd systemctl daemon-reload
	}

	# fix a systemd bug of xenial 16.04
	# https://askubuntu.com/questions/1109934/ssh-server-stops-working-after-reboot-caused-by-missing-var-run-sshd
	x=/usr/lib/tmpfiles.d/sshd.conf
	grep -q '/var' $x && {
		Msg.info "Fixing a little systemd bug that prevent SSHd to start"
		sed -i $x -e 's|/var||'
#		cmd mkdir -p -m0755 /var/run/sshd
	}

	# activate on firewall & restart SSH
	Fw.allow 'ssh'
	Msg.info "The SSH server is listening on port: $p"
}	# end install_openssh
