# ------------------------------------------------------------------------------
# install a self-signed certificate
# ------------------------------------------------------------------------------

install_sslcert_selfsigned() {
	# create a self-signed certificate
	local D=/etc/ssl/myserver
	mkdir -p "${D}"		# create the parent directory
	D="${D}/server"		# certificate path prefix

	# abort if certificate is already generated
	[ -r "${D}.cert" ] && {
		Msg.warn "SSL Certificate ( ${D}.cert ) is already generated..."
		return
	}

	Msg.info "Generating self-signed SSL Certificate..."

	# write the certificate
	openssl rand -out ~/.rnd -hex 256
	openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
		-keyout "${D}.key" -out "${D}.cert" \
		-subj "/C=${CERT_C}/ST=${CERT_ST}/L=${CERT_L}/O=${CERT_O}/OU=${CERT_OU}/CN=${CERT_CN}/emailAddress=${CERT_E}"
#	chmod 600 "${D}.key"

	# symlink the certificate paths
	sslcert_paths "${D}.key" "${D}.cert"

	Msg.info "Generation of self-signed SSL Certificate completed!"
}	# end install_sslcert_selfsigned
