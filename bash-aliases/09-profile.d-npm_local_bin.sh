# shellcheck shell=bash
npm config set prefix "${HOME}/.local"
# Add ~/.local/bin to the path.  It is where npm puts things you install when you run it without sudo.
if [ -e "${HOME}/.local/bin" ]; then
	# shellcheck disable=SC1090
	source "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../bash-common.sh"
	PATH="$(prepend_path "${PATH}" "${HOME}/.local/bin")"
fi
