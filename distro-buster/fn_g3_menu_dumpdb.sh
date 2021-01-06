# ------------------------------------------------------------------------------
# produce a backup file for every database on this server
# require a configured ~/.my.cnf, for credentials
# ------------------------------------------------------------------------------
# add this in /etc/crontab to dump MySQL databases at 13:07 and 20:07
# 7 13,20 * * * root bash ~/lin*/arrange.sh dumpdb > /dev/null 2>&1
# ------------------------------------------------------------------------------

menu_dumpdb() {
	# creating a new database
	# $1 db name - if provided it backup only this db

	# sanity check
	is_available "mysql" || return

	local B C D P Q="SHOW DATABASES;"

	# on passed arguments change query
	(( $# )) && Q="SHOW DATABASES LIKE '%${*}%';"

	# creating the container folder
	C="/var/backups/dumpdbs"
	mkdir -p "${C}"

	# set static blacklist
	B="# Database information_schema mysql performance_schema #"

	# show all databases without print labels
	for D in $(cmd mysql -Ne "${Q}"); do
		[[ ${B} = *${D}* ]] && continue		# skip db in blacklist
		P="${C}/${D}.sql.gz"
		cmd mysqldump --force -h 127.0.0.1 ${D} | cmd gzip > ${P}
		msg_info "Database '${D}' on '$(cmd date '+%F %H:%M')' saved to: '${P}'"
	done
}	# end menu_dumpdb
