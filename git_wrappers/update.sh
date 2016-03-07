#!/bin/bash

## `git updat e-c` is a common typo when fingers outpace brains.  Git will correctly guess that you meant `git update` but not that you meant `git update -c`.
if [ "$1" == "-c" -o "$1" == "--clean" -o "$1" == "e-c" ]; then
	if [ -f ./pins.json ]; then
		sed -nre 's/^[ \t]+"(.+)": \{/\1/p' ./pins.json | tee >(xargs rm -rf)
	fi
	find ./ -not \( -name .git -prune -or -name .svn -prune \) -name externals.json | while read; do
		echo "Removing externals from: $REPLY"
		sed -nre 's/^[ \t]+"(.+)": \{/\1/p' "$REPLY" | tee >(xargs rm -rf)
	done
	echo "Removing '.git/externals/' and likely external directories: " x_*
	rm -rf .git/externals x_* 2>/dev/null
fi

if [ -x ./git_setup.py ]; then
	./git_setup.py -kq
elif [ -f ./.gitsvnextmodules -o -f ./externals.json ]; then
	getdep
fi
if [ -f ./deps.json ]; then
	courier
fi

