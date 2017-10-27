#!/bin/bash

HERE="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
DOTFILES="$(dirname "${HERE}")"
#source "${DOTFILES}/bash_common.sh" 2>/dev/null && eval "${capture_output}" || true
source "${DOTFILES}/bash_common.sh" && eval "${setup_log_fd}" || true
source "${DOTFILES}/bash_aliases/39-aliases-opti_dev_aliases.sh"

log "$@"
set +e

IMAGES="$(docker-list.sh | sort -u)"
DOCKER_RUN_ARGS=()
while [ $# -ne 0 ] && ! echo "$IMAGES" | grep -qE "$1"'$' 2>/dev/null >/dev/null; do
	DOCKER_RUN_ARGS[${#DOCKER_RUN_ARGS[@]}]="$1"
	shift
done
IMAGE="$1"
shift

# user specific container name
IMAGE_NAME="$(basename -- "$IMAGE" | sed -re 's/^([^:]+)(:.+)?$/\1/')"
NAME="${IMAGE_NAME}-$(whoami)-$(date "+%s")"
echo "Starting $NAME ($IMAGE)"
docker inspect "$IMAGE" 2>&${log_fd} | jq '.[0].ContainerConfig.Labels' 2>&${log_fd} || true

# Use a docker container to do things
mkdir --parents "${HOME}/.cache/docker-run" 2>/dev/null || true
TMP="$(mktemp -p "${HOME}/.cache/docker-run" -t ".$(date '+%Y%m%d-%H%M%S').docker.${IMAGE_NAME}.XXXXXXXXXX")"
NODIR="$(mktemp -d)"
trap 'ec=$?; echo && echo "Leaving $NAME (${IMAGE})" && echo "Ran: $@" && echo "Exit code: $ec" && rm -fr "${TMP}" "${NODIR}"' EXIT
command cat >"$TMP" <<-EOF
	#!/bin/bash -i
	source ~/.bashrc
	export PS1="(docker:$(basename -- "$IMAGE")) $PS1"
	"\$@"
EOF
chmod u+x "$TMP"

proxy_exe "/optiver/bin/dockerme" "e377e9746adfa1f2d28b394e31e5f6e5"

function run()
{
	log "$@"
	echo "$@"
	echo
	"$@"
	es=$?
	echo
	log "Returns=$es"
	return $es
}
run dockerme -h "$(hostname)" --cpu-shares="$(nproc)" --privileged --name="${NAME}" \
	-v /etc/sudo.conf:/etc/sudo.conf:ro -v /etc/sudoers:/etc/sudoers:ro -v /etc/sudoers.d:/etc/sudoers.d:ro -v /etc/pam.d:/etc/pam.d:ro -v /etc/localtime:/etc/localtime:ro \
	--env-file=<(/usr/bin/env) -v "${TMP}:${TMP}" --entrypoint="$TMP" -v "${NODIR}:${HOME}/opt" \
	"${DOCKER_RUN_ARGS[@]}" "$IMAGE" "$@"
es=$?

proxy_exe "/optiver/bin/dockerme" "e377e9746adfa1f2d28b394e31e5f6e5"
exit $es
