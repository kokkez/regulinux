# ------------------------------------------------------------------------------
# simple password generator
# ------------------------------------------------------------------------------

Menu.mnemonic() {
	# metadata for OS.menu entries
	__section='Standalone utilities'
	__summary='mnemonic password of 2 words separated by a dash'

	# return a psedo mnemonic password of 2 words separated by a dash
	local f p w u="https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt"
	w=$(curl -s "$u" | awk 'length($2) > 3 && length($2) < 7 { print $2 }')
	# save a password that have at least 3 substitutions to do
	while :; do
		p=$(shuf -n2 <<< "$w" | paste -sd-)
		[[ $(tr -cd 'lzeasbtbg' <<< "$p" | wc -c) -gt 2 ]] && break
	done
	# substitute "lzeasbtbg" with "123456789", then return the password
	echo "${p^}" | perl -pe '@m=/([lzeasbtbg])/g; s/$m[-2]/index("lzeasbtbg",$m[-2]) + 1/e'
}	# end Menu.mnemonic


Pw.generate() {
	# $1 number of characters (defaults to 24)
	# $2 flag for strong password (defaults no)

	# constrain the length of the password, default 24
	local c n=$(( ${1//[^0-9]/} + 0 ))
	n=$(( n == 0 ? 24 : n > 32 ? 32 : n < 6 ? 6 : n ))

	# define chars, adding specials for strong password
	[[ $2 ]] && c='!#$%&*+\-.:<=>?@[]^A-Za-z0-9' || c='A-Za-z0-9'

	LC_ALL=C tr -dc "$c" < /dev/urandom | head -c $n; echo
}	# end Pw.generate


Menu.pw() {
	# metadata for OS.menu entries
	__section='Standalone utilities'
	__summary="print a random pw: \$1: length (6 to 32, 24), \$2: flag strong"

	# generate a random password (min 6 max 32 chars)
	Pw.generate "$@"
}	# end Menu.pw
