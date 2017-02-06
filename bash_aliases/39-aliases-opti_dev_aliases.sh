alias logarchive='ssh central-archive'
alias log-archive='ssh central-archive'
alias centralarchive='ssh central-archive'
alias central-archive='ssh central-archive'
alias centralstaging='ssh central-staging'
alias central-staging='ssh central-staging'

alias sshrelay='ssh sshrelay'

unalias bt 2>/dev/null
function bt()
{
	for f in "$@"; do
		file "$f"
		exe="$(file "$f" | sed -nre "s/.+, from '([^ ]+).+/\\1/p")"
		echo "bt $exe $f"
		echo
		( cd "$(dirname "$f")" && gdb -x <(echo bt) "$exe" "$(basename "$f")" )
	done
}

alias cc-env="docker-run.sh $(sed -nre 's!.+(docker-registry\.aus\.optiver\.com/[^ ]+/[^ ]+).*!\1!p' /usr/local/bin/cc-env | tail -n1)"

alias operat='/usr/bin/sudo -iu operat'

## OMG, so dodgy...
alias taskset='/usr/bin/sudo -Eu operat /usr/bin/sudo taskset -c 1'
alias asroot='/usr/bin/sudo -Eu operat /usr/bin/sudo'
alias asoperat='/usr/bin/sudo -Eu operat'
