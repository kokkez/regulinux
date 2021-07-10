# ------------------------------------------------------------------------------
# produce a backup file for every database on this server
# require a configured ~/.my.cnf, for credentials
# ------------------------------------------------------------------------------
# add this in /etc/crontab to dump MySQL databases at 13:07 and 20:07
# 7 13,20 * * * root bash ~/lin*/os.sh dumpdb > /dev/null 2>&1
# ------------------------------------------------------------------------------

menu_dumpdb() {
	# $1 db name - if provided it backup only this db

	# sanity check
	is_available "mysql" || return

	local B C D P Q="SHOW DATABASES;"

	# if are there arguments, then change query
	(( $# )) && Q="SHOW DATABASES LIKE '%${*}%';"

	# creating the container folder
	C="/var/backups/dumpdbs"
	mkdir -p "${C}"

	# set static blacklist
	B="information_schema|mysql|performance_schema"

	# show databases NOT blacklisted, silently & without labels
	# mysql -B : --batch
	# mysql -N : --skip-column-names
	for D in $(cmd mysql -BNe "${Q}" | grep -vP "${B}"); do
		P="${C}/${D}.sql.gz"
		cmd mysqldump --single-transaction --routines --quick --force ${D} | \
			cmd gzip --best --rsyncable > ${P}
		Msg.info "$(cmd date '+%F %T') database '${D}' saved to: '${P}'"
	done
}	# end menu_dumpdb
