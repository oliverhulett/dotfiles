#!/bin/bash

source "${HOME}/dot-files/bash_common.sh"
eval "${capture_output}"

EXTERNALS="$(git ls-files '*externals.json' '*deps.json')"

git pull --all
git update 2>/dev/null >/dev/null

echo
python - ${EXTERNALS} <<EOF
import os
import sys
import json
import subprocess

def do_file(name):
    global files
    with open(name) as f:
        xternals = json.load(f)
    if '@import' in xternals:
        files += [os.path.join(n, 'externals.json') for n in xternals['@import']]
    for key in xternals.iterkeys():
        d = os.path.join(os.path.dirname(name), key)
        if 'ref' in xternals[key] and (xternals[key]['ref'] == 'master'):
            p = subprocess.Popen(['git', 'tags', '1'], stdout=subprocess.PIPE, cwd=d)
            out, _ = p.communicate()
            try:
                tag = out.strip().split()[6]
                print 'Tagging external {0} @ {1}'.format(key, tag)
                if 'rev' in xternals[key]:
                    del xternals[key]['rev']
                xternals[key]['ref'] = tag
            except:
                pass
    with open(name, 'w') as f:
        json.dump(xternals, f, indent=4)

files = sys.argv[1:]
while len(files) > 0:
    do_file(files.pop(0))
EOF

for d in $(git submodule foreach --quiet pwd); do
	if [ "$(cd $d && git rev-parse --abbrev-ref HEAD)" == "master" ]; then
		tag="$( cd $d && git tags 1 | cut -f7 -d' ')"
		if [ -n "$tag" ]; then
			( cd $d && git checkout "$tag" ) && git add $d
		fi
	fi
done

## Pin... (Will also update...)
git pin
echo
## Unpin non-tags... (Will also update...)
git unpin

