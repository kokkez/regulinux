#!/bin/bash
# ------------------------------------------------------------------------------
# download and update bind zones if changed
# version 2.2 ( 2025-09, lock + mktemp + trap cleanup )

# ---------------------------------------------------------------- variables ---
LCK="${0##*/}"									# script name
LCK="/run/${LCK%.*}.lock"						# lock file path

#URL='http://185.75.242.23/dns-slave-data.php'	# url of master (amsium)
URL='http://85.209.17.132/dns-slave-data.php'	# url of master (chicum)
BND="/etc/bind/named.conf.local"				# final file path into bind/


# ---------------------------------------------------------------- functions ---
# print timestamp + message to stdout
log() { printf '%s [%d] %s\n' "$(date '+%F %T%:z')" "$$" "$*"; }
cleanup() { rm -f "$TMP" "$LCK"; }
trap cleanup EXIT INT TERM


# --------------------------------------------------------------------- LOCK ---
exec 200>"$LCK" || exit 1						# open fd 200 for lock
if ! flock -n 200; then							# try non-blocking exclusive lock
    log "another instance is running, exiting"
    exit 0
fi


# ------------------------------------------------------------------ program ---
# work in /tmp
TMP=$(mktemp /tmp/bind.zones.XXXXXX)			# temp file unique
cd /tmp || { log "cannot cd /tmp"; exit 1; }

# downloading the updated file from master dns
if ! wget -qO "${TMP}" --timeout=10 --tries=3 "${URL}?$RANDOM"; then
	log "ERROR: file not downloaded!"
    exit 1
fi

# compare with existing for differencies
log "file downloaded successfully, computing differences..."
if cmp -s "${BND}" "${TMP}"; then
	log "file content not changed"
	exit 0
fi

# atomic swap: move temp file over original with correct permissions
log "file content was changed, replacing file..."
install -m 644 -o bind -g bind "${TMP}" "${BND}"

# reload bind
if ! rndc reload &>/dev/null; then
	log "WARNING: rndc reload failed"
    exit 1
fi

log "update completed"

