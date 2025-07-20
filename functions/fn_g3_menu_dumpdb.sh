# ------------------------------------------------------------------------------
# produce a backup file for every database on this server
# require a configured ~/.my.cnf, for credentials
# ------------------------------------------------------------------------------
# add this in /etc/crontab to dump MySQL databases at 13:07 and 20:07
# 7 13,20 * * * root bash ~/*/os.sh dumpdb > /dev/null 2>&1
# ------------------------------------------------------------------------------

Menu.dumpdb() {
	__exclude="! Cmd.usable mysqldump"
	__section="Others applications"
	__summary="to backup all databases, or the one given in $(Dye.fg.white \$1)"

	# $1 - db name, optional, if provided will be backed up only that db

	# stop here if mysql cannot be called
	Cmd.usable "mysql" || return

	local b c d z q="SHOW DATABASES;"

	# if are there arguments, then change query
	(( $# )) && q="SHOW DATABASES LIKE '%${*}%';"

	# creating the container folder
	c='/var/backups/dumpdbs'
	mkdir -p "$c"

	# set static blacklist
	b='information_schema|mysql|performance_schema'

	# show databases NOT blacklisted, silently & without labels
	# mysql -B : --batch
	# mysql -N : --skip-column-names
	for d in $(cmd mysql -BNe "$q" | grep -vP "$b"); do
		z="$c/$d.sql.gz"
		cmd mysqldump --single-transaction --routines --quick --force "$d" \
			| cmd gzip --best --rsyncable > "$z"
		Msg.info "$( Date.fmt ) database '$d' saved to: '$z'"
	done
}	# end Menu.dumpdb
