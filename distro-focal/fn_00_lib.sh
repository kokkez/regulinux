# ------------------------------------------------------------------------------
# customized functions for ubuntu 20.04 focal
# ------------------------------------------------------------------------------

help_menu() {
	# display the main menu on screen
	local S O=""

	# Basic menu options
	S=""
	is_available "menu_ssh" && {
		S+="   . ${cORNG}ssh${cNULL}         setup private key, shell, SSH on port ${cWITELITE}${SSHD_PORT}${cNULL}\n"; }
	is_available "menu_deps" && {
		S+="   . ${cORNG}deps${cNULL}        check dependencies, update the base system, setup firewall\n"; }
	[ -z "${S}" ] || {
		O+=" [ . ${cWITELITE}Basic menu options${cNULL} ---------------------------- (in recommended order) -- ]\n${S}"; }

	# Standalone utilities
	S=""
	is_available "menu_upgrade" && {
		S+="   . ${cORNG}upgrade${cNULL}     apt full upgrading of the system\n"; }
	is_available "menu_password" && {
		S+="   . ${cORNG}password${cNULL}    print a random pw: \$1: length (6 to 32, 24), \$2: flag strong\n"; }
	is_available "menu_iotest" && {
		S+="   . ${cORNG}iotest${cNULL}      perform the classic I/O test on the VPS\n"; }
	[ -z "${S}" ] || {
		O+=" [ . ${cWITELITE}Standalone utilities${cNULL} ------------------------ (in no particular order) -- ]\n${S}"; }

	# Main applications
	S=""
	is_available "menu_mailserver" && {
		S+="   . ${cORNG}mailserver${cNULL}  full mailserver with postfix, dovecot & aliases\n"; }
	is_available "menu_dbserver" && {
		S+="   . ${cORNG}dbserver${cNULL}    the DB server MariaDB, root pw in ${cWITELITE}~/.my.cnf${cNULL}\n"; }
	is_available "menu_webserver" && {
		S+="   . ${cORNG}webserver${cNULL}   webserver apache2 or nginx, with php, selfsigned cert, adminer\n"; }
	[ -z "${S}" ] || {
		O+=" [ . ${cWITELITE}Main applications${cNULL} ----------------------------- (in recommended order) -- ]\n${S}"; }

	# Target system
	S=""
	is_available "menu_dns" && {
		S+="   . ${cORNG}dns${cNULL}         bind9 DNS server with some related utilities\n"; }
	is_available "menu_assp1" && {
		S+="   . ${cORNG}assp1${cNULL}       the AntiSpam SMTP Proxy version 1 (min 384ram 1core)\n"; }
	is_available "menu_ispconfig" && {
		S+="   . ${cORNG}ispconfig${cNULL}   historical Control Panel with support at ${cWITELITE}howtoforge.com${cNULL}\n"; }
	[ -z "${S}" ] || {
		O+=" [ . ${cWITELITE}Target system${cNULL} ------------------------------- (in no particular order) -- ]\n${S}"; }

	# Others applications
	S=""
	is_available "menu_dumpdb" && {
		S+="   . ${cORNG}dumpdb${cNULL}      perform the backup of all databases, or the one given in \$1\n"; }
	is_available "menu_roundcube" && {
		S+="   . ${cORNG}roundcube${cNULL}   full featured imap web client\n"; }
	is_available "menu_nextcloud" && {
		S+="   . ${cORNG}nextcloud${cNULL}   on-premises file share and collaboration platform\n"; }
	is_available "menu_espo" && {
		S+="   . ${cORNG}espo${cNULL}        EspoCRM full featured CRM web application\n"; }
	is_available "menu_acme" && {
		S+="   . ${cORNG}acme${cNULL}        shell script for Let's Encrypt free SSL certificates\n"; }

	echo -e " $(date '+%Y-%m-%d %T %z') :: ${cORNG}${OS} (${DISTRO}) ${ARCH}${cNULL} :: ${MyDir}\n${S}
 -------------------------------------------------------------------------------"
}	# end help_menu

