#!/bin/bash

HERE="$(dirname "$(readlink -f "$0")")"
DOTFILES="$(dirname "${HERE}")"
source "${DOTFILES}/bash_common.sh" 2>/dev/null && eval "${capture_output}" || true

## Old versions of git play with the path.  Old versions of git are correlated with old versions of Centos, which means old versions of python.
## If we need a python venv in out bash setup, assume we need it here too.
if [ -e "${HOME}/.bash_aliases/09-profile.d-pyvenv.sh" ]; then
	source "${HOME}/.bash_aliases/09-profile.d-pyvenv.sh"
fi

EXTERNALS="$(git ls-files '*externals.json')"

git update 2>&${log_fd} >&${log_fd}

echo
echo "Pinning externals"
export PYTHONPATH="${HOME}/repo/pyu/git_utils/master"
for d in "${EXTERNALS}"; do
	( cd $(dirname $d) && python -m git_utils.pin_externals )
	python -m json.tool $d >&${log_fd} && echo "$(python -m json.tool $d)" > $d
done
echo

git update 2>&${log_fd} >&${log_fd}
