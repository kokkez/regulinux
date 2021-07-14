#!/bin/bash
# ------------------------------------------------------------------------------
# download and update the active zones for bind


# ---------------------------------------------------------------- variables ---
URL='http://inzium.rete.us/dns-slave-data.php'	# url of primary
LP='/etc/bind'									# local path
FN='named.conf.slaves'							# file name


# ------------------------------------------------------------------ program ---
# work in /tmp
cd /tmp

# downloading the remote file
wget -qO "${FN}" "${URL}"
#echo $?
if [ $? -ne 0 ]; then
	echo "ERROR: file not downloaded!"
	exit 1
fi;

# comparing for differences
echo "file downloaded successfully, computing differences..."
cmp -s "${LP}/${FN}" "${FN}"
#echo $?
if [ $? -eq 0 ]; then
	echo "file content not changed"
	exit 0
fi;

# remove old file
echo "file content was changed, replacing file..."
mv -f "${FN}" "${LP}/"

# reload bind
command rndc reload
#invoke-rc.d bind9 force-reload


