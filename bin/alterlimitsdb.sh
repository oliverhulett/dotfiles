#!/bin/bash
#
#	Wrapper for the alterlimitsdb python module.
#
HERE="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
DOTFILES="$(dirname "${HERE}")"
source "${DOTFILES}/bash_common.sh" 2>/dev/null && eval "${capture_output}" || true

set -x

if [ -z "$ALTERLIMITSDB_DIR" ]; then
	clone.sh limits_system limits_server
	export ALTERLIMITSDB_DIR="$(get-repo-dir.sh limits_system limits_server alterlimitsdb)"
fi
if [ -z "$ALTERLIMITSDB_DIR" ] || [ ! -d "$ALTERLIMITSDB_DIR" ]; then
	echo "\$ALTERLIMITSDB_DIR is not set or is not a directory: $ALTERLIMITSDB_DIR" >&2
	exit 1
fi
if [ -z "$DB_URI" ]; then
	export DB_URI='postgresql://operat@devenv002:6002/limitsdb_ml'
fi

cd "${ALTERLIMITSDB_DIR}" || exit 1
python26 -m Server.DataModel.alterlimitsdb --db="$DB_URI" "$@"
