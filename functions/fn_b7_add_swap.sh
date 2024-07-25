# ------------------------------------------------------------------------------
# add a swap file on KVM or DEDI systems that dont have one
# ------------------------------------------------------------------------------

Swap.notContainer() {
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
	Msg.info "Not a container, can continue..."
	return 0
}	# end Swap.notContainer


Swap.notExists() {
	# returns 1 (error) if the current system already has a swap
	[ -n "$(cmd swapon -s)" ] && {
		Msg.warn "Swap alreay exists..."
		return 1
	}
	Msg.info "The system does not have a swap, can continue..."
	return 0
}	# end Swap.notExists


Swap.havespace() {
	# returns 1 (error) if the current system has insufficient disk space
	# $1 - size of the file to compare
	local p=$(Partition.space) s=$(Unit.convert "$1")
	(( p > s )) || {
		Msg.warn "Insufficient disk space for a swap file of $1..."
		return 1
	}
	p=$(cmd numfmt --to=iec-i --suffix=B $((p * 1024)))
	Msg.info "The system has enough space, $p, for a swap file of $1, can continue..."
	return 0
}	# end Swap.havespace


Menu.addswap() {
	# add a file to be used as SWAP memory
	# $1 - size of the swap file, optional
	# $2 - path to the swap file, optional
	local z=${1:-512M} f=${2:-/swapfile}

	# do checks
	Swap.notContainer || return 1
	Swap.notExists || return 1
	Swap.havespace "$z" || return 1

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
