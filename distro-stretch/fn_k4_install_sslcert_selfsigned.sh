# ------------------------------------------------------------------------------
# install a self-signed certificate
# ------------------------------------------------------------------------------

install_sslcert_selfsigned() {
	# create a self-signed certificate
	local d=/etc/ssl/myserver
	mkdir -p "$d"		# create the parent directory
	d="$d/server"		# certificate path prefix

	# abort if certificate is already generated
	[ -r "${d}.cert" ] && {
		Msg.warn "SSL Certificate ( ${d}.cert ) is already generated..."
		return
	}

	Msg.info "Generating self-signed SSL Certificate..."

	# write the certificate
	openssl rand -out ~/.rnd -hex 256
	openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
		-keyout "${d}.key" -out "${d}.cert" \
		-subj "/C=${CERT_C}/ST=${CERT_ST}/L=${CERT_L}/O=${CERT_O}/OU=${CERT_OU}/CN=${CERT_CN}/emailAddress=${CERT_E}"
#	chmod 600 "${d}.key"

	# symlink the certificate paths
	sslcert_paths "${d}.key" "${d}.cert"

	Msg.info "Generation of self-signed SSL Certificate completed!"
}	# end install_sslcert_selfsigned
