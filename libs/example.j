// example -- a tiny library that shows the format of a library for jget (this file is the whole library).
//   library: example      version: 1.0      needs: jcmp 0.9.183 or newer      license: free to use, copy and change
// Install:   jget -li install example        Use:   #import <example>      then   cout << example_greeting("J2K") << nl;
//
// A library is ONE source file. It declares functions, structs and globals like any J2K file. Names should start with the
// name of the library (example_...) so that two libraries do not clash. Nothing here runs when it is installed.

String example_greeting(String who) {
    return "hello, " + who;
}

int example_twice(int x) {
    return x * 2;
}
