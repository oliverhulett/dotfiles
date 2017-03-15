#!/bin/bash
#
#	Run an SSH command on the development servers.
#
source "${HOME}/dot-files/bash_common.sh"
eval "${capture_output}"

declare -a DEV_SRVS=( $(ssh-ping.sh 2>/dev/null | sort -u) )

trap wait EXIT

for srv in "${DEV_SRVS[@]}"; do
	if [ -z "$srv" ]; then
		continue
	fi
	if [ "$srv" = "localhost" ]; then
		continue
	fi
	if [ "$srv" = "$(hostname)" ]; then
		continue
	fi
	echo "Server: $srv  ============================================================================"
	ssh ${USER}@${srv} "$@" 2>&${log_fd} &
	echo
done
