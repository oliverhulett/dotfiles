# shellcheck shell=bash
## Source things from the brew prefix etc/ dir.
# shellcheck disable=SC1090

if reentered "${HOME}/.bash-aliases/09-profile.d-brew.sh"; then
	return 0
fi

# Alias gnu utils installed on the mac with homebrew to their usual names.
## Do we need to detect mac-ness?
## This should work on linux too (mostly it'll be a no-op, worst case it create some useless links)
## There is some risk that this doesn't happen early enough.  As long as it does eventually happen though, subsequent loads should work.
(
	for f in /usr/local/bin/g*; do
		g="$(basename -- "$f")"
		if [ "$g" != 'g[' ] && [ ! -e "/usr/local/bin/${g:1}" ]; then
			( cd /usr/local/bin/ && ln -s "$g" "${g:1}" 2>/dev/null )
		fi
	done
	# Doesn't work, for some reason.
	rm '/usr/local/bin/[' 2>/dev/null || true
) &

source "$(brew --prefix)/etc/bash_completion"
source "$(brew --prefix)/etc/profile.d"/*.sh

PATH="$(append_path "${PATH}" "/usr/local/opt/gettext/bin")"
export PATH