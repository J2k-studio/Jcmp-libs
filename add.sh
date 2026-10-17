#!/bin/sh
# add.sh NAME VERSION FILE URL -- append a line to index.txt (the SHA-256 of FILE is computed here)
set -eu
[ $# -eq 4 ] || { echo "usage: add.sh NAME VERSION FILE URL"; exit 1; }
case "$1" in *[!A-Za-z0-9_]*|"") echo "add: the name must be letters, digits and _ only"; exit 1;; esac
grep -q "^$1 " index.txt && { echo "add: $1 is already in the index"; exit 1; }
H="$(sha256sum "$3" | cut -d' ' -f1)"
echo "$1 $2 $4 $H" >> index.txt
echo "added $1 $2 ($H)"
