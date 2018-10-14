# shellcheck shell=bash

function _pipenv_completion() {
	local IFS=$'\t'
	COMPREPLY=( $( env COMP_WORDS="${COMP_WORDS[*]}" \
		COMP_CWORD="$COMP_CWORD" \
		_PIPENV_COMPLETE=complete-bash "$1" ) )
	return 0
}

complete -F _pipenv_completion -o default pipenv
