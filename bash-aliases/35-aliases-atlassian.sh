# shellcheck shell=bash
## Atlassian aliases
alias tricorder='docker pull docker.atl-paas.net/ath; docker run --rm docker.atl-paas.net/ath | sh'
alias vgrok='ngrok start jira-exploratory-development &'
## Actually run vgrok so that it is "always" running
( exec >/dev/null 2>/dev/null; vgrok )

## JMake doesn't like MAVEN_OPTS being set.  :(
#export MAVEN_OPTS="${MAVEN_OPTS} -Djansi.force=true"

function jirareleased()
{
	repo jira || return 1
	git pullme
	echo
	HASH="${1:-$(git mylasthash)}"
	echo "Branches containing ${HASH}"
	git branch --contains "${HASH}"
	cd - || return 1
}
