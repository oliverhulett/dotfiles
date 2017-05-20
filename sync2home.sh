#!/bin/bash
set -e

HERE="$(dirname "${BASH_SOURCE[0]}")"
cd "${HERE}" || ( echo "Failed to enter run directory"; exit 1 )

OTHER_REMOTE="$(git remote | command grep -v origin)"
if [ -z "${OTHER_REMOTE}" ]; then
	echo "Can't merge; there's no other remote..."
	exit 0
fi
BRANCH="$(git this)"

echo "Pulling and fetching latest from remotes..."
git pullb
git fetch "$OTHER_REMOTE"

IGNORE_LIST="${HERE}/sync2home.ignore.txt"
HASH_FILE="${HERE}/.sync2home.last-hash"
echo "$(basename "${HASH_FILE}")" >>"${IGNORE_LIST}"
echo "$(sort -u "${IGNORE_LIST}" | sed -re '/^$/d')" >"${IGNORE_LIST}"
LAST_HASH="$(sed -ne '1p' "${HASH_FILE}")"
NEXT_HASH="$(git rev-parse "$OTHER_REMOTE/$BRANCH")"
echo
echo "Syncing from ${LAST_HASH} to $OTHER_REMOTE/$BRANCH (${NEXT_HASH})"

echo git format-patch --stdout -p ${LAST_HASH}..$OTHER_REMOTE/$BRANCH
git format-patch --stdout -p ${LAST_HASH}..$OTHER_REMOTE/$BRANCH | git apply --verbose --index --3way $(awk '{print "--exclude=" $0}' "${IGNORE_LIST}")

echo
echo "Committing last sync-ed hash: ${NEXT_HASH}"
echo ${NEXT_HASH} >"${HASH_FILE}"
git commit -a -m"Sync2Home autocommit: ${LAST_HASH} to ${NEXT_HASH}" --allow-empty
#git push
echo
echo "Done.  Sync-ed $OTHER_REMOTE/$BRANCH; from ${LAST_HASH} to ${NEXT_HASH}"