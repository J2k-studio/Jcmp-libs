# Jcmp-libs

The index of libraries for [jget](https://github.com/J2k-studio/Jcmp) (the fetch tool of the J2K language).

* `jget -li list` shows the libraries of `index.txt`; `jget -li install NAME` downloads one, checks its SHA-256 and puts it in `~/.j2k/Library`.
* A library is **one J2K source file** `NAME.j`. Nothing of it runs when it is installed.
* Add a library: put its file somewhere that has a public address (for example a file of this repository), then `./add.sh NAME VERSION FILE URL`, commit, push.
