#!/bin/sh
# tools/add.sh NAME VERSION [URL] -- put libs/NAME.j in index.txt: the line is  NAME VERSION URL SHA256
# URL is the address of the raw file in this repository unless you give another one (several: a|b|c, mirrors).
# An existing line of NAME is replaced. Run it from the root of the repository.
set -eu
[ $# -ge 2 ] || { echo "usage: tools/add.sh NAME VERSION [URL]"; exit 1; }
NAME="$1"; VER="$2"
case "$NAME" in *[!A-Za-z0-9_]*|"") echo "add: the name must be letters, digits and _ only"; exit 1;; esac
[ -f "libs/$NAME.j" ] || { echo "add: libs/$NAME.j does not exist"; exit 1; }
URL="${3:-https://raw.githubusercontent.com/J2k-studio/Jcmp-libs/main/libs/$NAME.j}"
SUM="$(sha256sum "libs/$NAME.j" | cut -d' ' -f1)"
grep -v "^$NAME " index.txt > index.txt.new || true
echo "$NAME $VER $URL $SUM" >> index.txt.new
# comments first, then the libraries in order of name
( grep '^#' index.txt.new; grep -v '^#' index.txt.new | grep -v '^$' | sort ) > index.txt
rm -f index.txt.new
echo "index.txt: $NAME $VER ($SUM)"
