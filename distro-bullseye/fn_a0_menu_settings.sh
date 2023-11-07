# ------------------------------------------------------------------------------
# read, creating if missing, the file with configurations for the installation
# ------------------------------------------------------------------------------

Menu.configs() {
	# write configurations on file
	local p="$ENV_dir/settings.conf"

	# creating file with the default values as defined in ./lib.sh
	[ -s "$p" ] || {
		cmd cat > "$p" <<-EOF
			TARGET="$TARGET"
			TIME_ZONE="$TIME_ZONE"
			SSHD_PORT="$SSHD_PORT"
			FW_allowed="$FW_allowed"
			HOST_NICK="$HOST_NICK"
			HOST_FQDN="$HOST_FQDN"
			ROOT_MAIL="$ROOT_MAIL"
			LENC_MAIL="$LENC_MAIL"
			MAIL_NAME="$MAIL_NAME"
			DB_rootpw=""
			ASSP_ADMINPW="$ASSP_ADMINPW"
			CERT_C="$CERT_C"
			CERT_ST="$CERT_ST"
			CERT_L="$CERT_L"
			CERT_O="$CERT_O"
			CERT_OU="$CERT_OU"
			CERT_CN="$CERT_CN"
			CERT_E="$CERT_E"
			HTTP_SERVER="$HTTP_SERVER"
			EOF
		Msg.info "Creation of config file $(Dye.fg.white $p) completed..."
	}

	cmd source "$p"
	Msg.info "Loading config file $(Dye.fg.white $p) completed!"
}	# end Menu.configs




