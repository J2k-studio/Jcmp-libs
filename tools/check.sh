#!/bin/sh
# tools/check.sh -- the index must be good: every line has four fields, a valid name, a 64-digit checksum; a library of this repository
# (libs/NAME.j) must have the checksum of its file; the names are unique. Exit code 0: good.
cd "$(dirname "$0")/.." || exit 1
bad=0
for f in libs/*.j; do
    [ -f "$f" ] || continue
    n="$(basename "$f" .j)"
    grep -q "^$n " index.txt || { echo "check: libs/$n.j is not in index.txt (tools/add.sh $n VERSION)"; bad=1; }
done
grep -v '^#' index.txt | grep -v '^[[:space:]]*$' | while read -r name ver url sum rest; do
    case "$name" in *[!A-Za-z0-9_]*|"") echo "check: bad name '$name'"; exit 1;; esac
    [ -n "$ver" ] && [ -n "$url" ] || { echo "check: $name has fewer than four fields"; exit 1; }
    case "$sum" in *[!0-9a-f]*|"") echo "check: $name: the checksum is not hex"; exit 1;; esac
    [ "${#sum}" = 64 ] || { echo "check: $name: the checksum is not 64 digits"; exit 1; }
    if [ -f "libs/$name.j" ]; then
        have="$(sha256sum "libs/$name.j" | cut -d' ' -f1)"
        [ "$have" = "$sum" ] || { echo "check: $name: the checksum differs from libs/$name.j (run tools/add.sh $name $ver)"; exit 1; }
    fi
done || bad=1
dups="$(grep -v '^#' index.txt | grep -v '^[[:space:]]*$' | cut -d' ' -f1 | sort | uniq -d)"
[ -z "$dups" ] || { echo "check: names twice: $dups"; bad=1; }
[ "$bad" = 0 ] && echo "check: the index is good"
exit $bad
