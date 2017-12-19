## Call sort on files, write results back to files
function sortinline()
{
	KEEP_BLANK="no"
	ARGS=()
	FILES=()
	for f in "$@"; do
		if [ -f "$f" ]; then
			FILES[${#FILES[@]}]="$(readlink -e "$f")"
		else
			if [ "$f" == "--keep" ]; then
				KEEP_BLANK="yes"
			else
				ARGS[${#ARGS[@]}]="$f"
			fi
		fi
	done
	for f in "${FILES[@]}"; do
		echo "sort ${ARGS[@]} $f"
		echo "$(sort "${ARGS[@]}" "$f")" >"$f"
	done
	if [ "$KEEP_BLANK" == "no" ]; then
		cleaninline "${FILES[@]}"
	fi
}

## Call uniq on files, write results back to files
function uniqinline()
{
	KEEP_BLANK="no"
	ARGS=()
	FILES=()
	for f in "$@"; do
		if [ -f "$f" ]; then
			FILES[${#FILES[@]}]="$(readlink -e "$f")"
		else
			if [ "$f" == "--keep" ]; then
				KEEP_BLANK="yes"
			else
				ARGS[${#ARGS[@]}]="$f"
			fi
		fi
	done
	for f in "${FILES[@]}"; do
		echo "uniq ${ARGS[@]} $f"
		echo "$(uniq "${ARGS[@]}" "$f")" >"$f"
	done
	if [ "$KEEP_BLANK" == "no" ]; then
		cleaninline "${FILES[@]}"
	fi
}

## Clean files of empty lines, write result back to files
function cleaninline()
{
	ARGS=()
	FILES=()
	for f in "$@"; do
		if [ -f "$f" ]; then
			FILES[${#FILES[@]}]="$(readlink -e "$f")"
		else
			ARGS[${#ARGS[@]}]="$f"
		fi
	done
	for f in "${FILES[@]}"; do
		echo "sed -re '/^$/d' ${ARGS[@]} -i $f"
		sed -re '/^$/d' "${ARGS[@]}" -i "$f"
	done
}

## Convert spaces to tabs, write result back to files
function unexpandinline()
{
	ARGS=()
	FILES=()
	has_dash_t="no"
	for f in "$@"; do
		if [ -f "$f" ]; then
			FILES[${#FILES[@]}]="$(readlink -e "$f")"
		else
			ARGS[${#ARGS[@]}]="$f"
			if [ "${f[0]}" == "-" ] && [ "${f[1]}" == "t" ]; then
				has_dash_t="yes"
			fi
		fi
	done
	if [ "${has_dash_t}" == "no" ]; then
		ARGS[${#ARGS[@]}]="-t4"
	fi
	for f in "${FILES[@]}"; do
		echo "unexpand ${ARGS[@]} $f"
		echo "$(unexpand "${ARGS[@]}" "$f")" >"$f"
	done
}

## Convert tabs to spaces, write result back to files
function expandinline()
{
	ARGS=()
	FILES=()
	has_dash_t="no"
	for f in "$@"; do
		if [ -f "$f" ]; then
			FILES[${#FILES[@]}]="$(readlink -e "$f")"
		else
			ARGS[${#ARGS[@]}]="$f"
			if [ "${f[0]}" == "-" ] && [ "${f[1]}" == "t" ]; then
				has_dash_t="yes"
			fi
		fi
	done
	if [ "${has_dash_t}" == "no" ]; then
		ARGS[${#ARGS[@]}]="-t4"
	fi
	for f in "${FILES[@]}"; do
		echo "expand ${ARGS[@]} $f"
		echo "$(expand "${ARGS[@]}" "$f")" >"$f"
	done
}

## Add items to a list file.  Keep the list file sorted, uniq-ified, and clean of empty lines.
function list()
{
	ARGS=()
	LIST=()
	for a in "$@"; do
		if [ "${a:0:1}" == "-" ]; then
			ARGS[${#ARGS[@]}]="$a"
		else
			LIST[${#LIST[@]}]="$a"
		fi
	done
	FILE=""
	if [ ! -f "${LIST[0]}" -a -f "${LIST[$((${#LIST[@]} - 1))]}" ]; then
		FILE="${LIST[$((${#LIST[@]} - 1))]}"
		LIST=( "${LIST[@]:0:$((${#LIST[@]} - 1))}" )
	else
		FILE="${LIST[0]}"
		LIST=( "${LIST[@]:1}" )
	fi
	echo "Adding to file: ${FILE}"
	for l in "${LIST[@]}"; do
		echo "Adding: $l"
		echo "$l" >>"${FILE}"
	done
	sortinline -u "${FILE}"
}
