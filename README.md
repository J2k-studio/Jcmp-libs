# Jcmp-libs

The index of libraries for [jget](https://github.com/J2k-studio/jget), the download tool of the [J2K language](https://github.com/J2k-studio/Jcmp).

```
jget -li list                  the libraries of this index
jget -li install example       download, check the SHA-256, put in ~/.j2k/Library
```

then in your program: `#import <example>`.

## What is here

| Path | What |
|---|---|
| `index.txt` | the index: a line `NAME VERSION URL SHA256` for each library |
| `libs/NAME.j` | the source of a library of this repository (one file) |
| `tools/add.sh` | `tools/add.sh NAME VERSION [URL]` writes the line of a library (the checksum is computed) |
| `tools/check.sh` | checks the index (fields, names, checksums); run by GitHub on every push and pull request |
| `CONTRIBUTING.md` | how to add a library |

The libraries that come with the compiler (`cpu`, `net`, `math`, `text` ...) are **not** here: they are in the folder `Library` of every release of jcmp and need no install.

## Add a library

See [CONTRIBUTING.md](CONTRIBUTING.md). In short: one source file `libs/NAME.j`, then `tools/add.sh NAME 1.0`, `tools/check.sh`, commit, pull request.
A library can also live somewhere else: give its address as the third argument of `tools/add.sh` (several addresses separated by `|` are mirrors).
