#!/bin/bash

source "${HOME}/dot-files/bash_common.sh" 2>/dev/null && eval "${capture_output}" || true

echo "Saving known ignored files."
tmp="$(mktemp -d)"
find ./ -xdev -not \( -name '.git' -prune -or -name '.svn' -prune \) \( -name .project -or -name .pydevproject -or -name .cproject -or -name .settings \) -print0 | xargs -0 cp --parents -vxPr --target-directory="${tmp}/" 2>/dev/null

echo "Cleaning ignored files."
git clean -f -X -d

echo "Restoring known ignored files."
rsync -zvpPAXrogthlm "${tmp}/" ./ && rm -rf "${tmp}"
