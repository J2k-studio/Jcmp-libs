# Adding a library

1. **One file.** The library is one J2K source file, `libs/NAME.j`. `NAME` is letters, digits and `_` only (it becomes the file name and the word in `#import <NAME>`).
2. **Start with a comment**: what it is, the version, the version of jcmp it needs, the license, how to use it (see `libs/example.j`).
3. **Names**: begin the names of your functions, structs and globals with the name of the library (`example_greeting`), so that two libraries do not clash.
4. **Nothing runs on install**: a library is only source; it is compiled when a program imports it. Do not put anything in it that you would not want to run in someone's program.
5. **Test it**: `jcmp` a small program that imports it (`J2K_PATH=libs jcmp test.jk -o test`).
6. `tools/add.sh NAME VERSION` writes the line in `index.txt` (the SHA-256 is computed). When you change a library, raise the version and run it again.
7. `sh tools/check.sh` must say that the index is good; commit and open a pull request. The same check runs on GitHub.

A library that lives in your own repository: give the address of the raw file as the third argument of `tools/add.sh`. The checksum in the index is what `jget` checks, so a file that
is changed afterwards is refused (the index must be updated by a new pull request).

## Document your library
Add `examples/NAME.jk` (a short program that runs and prints something) and the descriptions of your functions in the table `D` of `tools/gendocs.py`, then `python3 tools/gendocs.py --jcmp jcmp` writes `docs/NAME.md`. A library without a page of docs is not accepted.
