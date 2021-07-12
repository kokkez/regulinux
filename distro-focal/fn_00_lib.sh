# ------------------------------------------------------------------------------
# customized functions for ubuntu 20.04 focal
# ------------------------------------------------------------------------------

OS.menu() {
	# display the main menu on screen
	local S O=""

	# Basic menu options
	S=""
	Cmd.usable "Menu.ssh" && {
		S+="   . $(Dye.fg.orange ssh)         setup private key, shell, SSH on port $(Dye.fg.white $SSHD_PORT)\n"; }
	Cmd.usable "Menu.deps" && {
		S+="   . $(Dye.fg.orange deps)        check dependencies, update the base system, setup firewall\n"; }
	[ -z "$S" ] || {
		O+=" [ . $(Dye.fg.white Basic menu options) ---------------------------- (in recommended order) -- ]\n$S"; }

	# Standalone utilities
	S=""
	Cmd.usable "Menu.upgrade" && {
		S+="   . $(Dye.fg.orange upgrade)     apt full upgrading of the system\n"; }
	Cmd.usable "Menu.password" && {
		S+="   . $(Dye.fg.orange password)    print a random pw: \$1: length (6 to 32, 24), \$2: flag strong\n"; }
	Cmd.usable "Menu.iotest" && {
		S+="   . $(Dye.fg.orange iotest)      perform the classic I/O test on the VPS\n"; }
	[ -z "$S" ] || {
		O+=" [ . $(Dye.fg.white Standalone utilities) ------------------------ (in no particular order) -- ]\n$S"; }

	# Main applications
	S=""
	Cmd.usable "Menu.mailserver" && {
		S+="   . $(Dye.fg.orange mailserver)  full mailserver with postfix, dovecot & aliases\n"; }
	Cmd.usable "Menu.dbserver" && {
		S+="   . $(Dye.fg.orange dbserver)    the DB server MariaDB, root pw in $(Dye.fg.white ~/.my.cnf)\n"; }
	Cmd.usable "Menu.webserver" && {
		S+="   . $(Dye.fg.orange webserver)   webserver apache2 or nginx, with php, selfsigned cert, adminer\n"; }
	[ -z "$S" ] || {
		O+=" [ . $(Dye.fg.white Main applications) ----------------------------- (in recommended order) -- ]\n$S"; }

	# Target system
	S=""
	Cmd.usable "Menu.dns" && {
		S+="   . $(Dye.fg.orange dns)         bind9 DNS server with some related utilities\n"; }
	Cmd.usable "Menu.assp1" && {
		S+="   . $(Dye.fg.orange assp1)       the AntiSpam SMTP Proxy version 1 (min 768ram 1core)\n"; }
	Cmd.usable "Menu.ispconfig" && {
		S+="   . $(Dye.fg.orange ispconfig)   historical Control Panel with support at $(Dye.fg.white howtoforge.com)\n"; }
	[ -z "$S" ] || {
		O+=" [ . $(Dye.fg.white Target system) ------------------------------- (in no particular order) -- ]\n$S"; }

	# Others applications
	S=""
	Cmd.usable "Menu.dumpdb" && {
		S+="   . $(Dye.fg.orange dumpdb)      perform the backup of all databases, or the one given in \$1\n"; }
	Cmd.usable "Menu.roundcube" && {
		S+="   . $(Dye.fg.orange roundcube)   full featured imap web client\n"; }
	Cmd.usable "Menu.nextcloud" && {
		S+="   . $(Dye.fg.orange nextcloud)   on-premises file share and collaboration platform\n"; }
	Cmd.usable "Menu.espo" && {
		S+="   . $(Dye.fg.orange espo)        EspoCRM full featured CRM web application\n"; }
	Cmd.usable "Menu.acme" && {
		S+="   . $(Dye.fg.orange acme)        shell script for Let's Encrypt free SSL certificates\n"; }

	echo -e " $(Date.fmt '+%F %T %z') :: $(Dye.fg.orange $ENV_os $ENV_arch) :: ${ENV_dir}\n$S
 [ ------------------------------------------------------------------------------------------- ]"
}	# end OS.menu

