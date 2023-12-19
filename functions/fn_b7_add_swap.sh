# ------------------------------------------------------------------------------
# add a swap file on KVM or DEDI systems that dont have one
# ------------------------------------------------------------------------------

Swap.iscontainer() {
	# returns 1 (error) if the current system is a virtualized container
	# container OpenVZ
	[ -d /proc/vz ] && {
		Msg.warn "No swap on OpenVZ containers..."
		return 1
	}
	# container LXC
	[ -d /proc/1/root/.local/share/lxc ] && {
		Msg.warn "No swap on LXC containers..."
		return 1
	}
}	# end Swap.iscontainer


Swap.exists() {
	# returns 1 (error) if the current system already has a swap
	[ -n "$(cmd swapon -s)" ] && {
		Msg.warn "Swap alreay exists..."
		return 1
	}
}	# end Swap.exists


Swap.havespace() {
	# returns 1 (error) if the current system has insufficient disk space
	# $1 - size of the file to compare
	(( $(Partition.space) > $(Unit.convert "$1") )) || {
		Msg.warn "Insufficient disk space for a swap file of $1..."
		return 1
	}
}	# end Swap.havespace


Menu.addswap() {
	# add a file to be used as SWAP memory
	# $1 - size of the swap file, optional
	# $2 - path to the swap file, optional
	local z=${1:-512M} f=${2:-/swapfile}

	# do checks
	Swap.iscontainer; (( $? )) && return
	Swap.exists; (( $? )) && return
	Swap.havespace; (( $? )) || return

	# install swap
	Msg.info "Implementing a swap file of $z in '$f'..."
#	swapoff $f
	cmd fallocate -l $z $f
	chmod 600 $f
	mkswap $f
	cmd swapon $f
	cmd swapon --show

	# activating permanently
	grep -q "$f" /etc/fstab || {
		Msg.info "Saving swap line into '/etc/fstab'..."
		echo "$f none swap sw 0 0" >> /etc/fstab
	}

	Msg.info "A swap file of $z was implemented in '$f' permanently!"
}	# end Menu.addswap
