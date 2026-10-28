# `<native>` — call the libraries of the system

Install: `jc lib install native`   Use: `#import <native>`   Build the program with `jcmp -dyn`.

`dlopen`, `dlsym` and calls of C functions from J2K; the program must be built with `jcmp -dyn`.

## About (the header of the library)

```
native 0.1.1 -- call the libraries of the system (Vulkan, OpenGL ES, OpenCL, libc ...) from J2K.   #import <native>   (needs jcmp 1.1.1 or newer; license: MPL-2.0)
int lib = Native::open("libvulkan.so");              // 0 when it is not there
int fn = Native::sym(lib, "vkEnumerateInstanceVersion");
int rc = Native::call1(fn, (int)@version);           // call1 .. call9: integer and pointer arguments, the result in x0
It works in a program built with  jcmp -dyn  (a dynamic executable: the loader of Android gives it libdl.so and libc.so) and in a
shared library (-l) that Android loads. A static program (the default) has no libdl: Native::open gives 0 there.
How: the memory of libdl.so is read (the maps of the process and its ELF tables) to find dlopen and dlsym, then they are called
through function pointers. Floating point arguments: callf1 .. callf4 (float arguments), callfd (double). Memory: peek / poke.
```

## Example

```jk
#import <stdlib>
#import <native>
int main() {
    int lib = Native::open("libvulkan.so");         // build with:  jcmp -dyn native.jk -o native
    if lib == 0 { cout << "no libvulkan (build with jcmp -dyn)\n"; return 1; }
    int fn = Native::sym(lib, "vkEnumerateInstanceVersion");
    char out[16];
    out[0] = 0; out[1] = 0; out[2] = 0; out[3] = 0;
    Native::call1(fn, (int)@out);
    int v = Native::peek32((int)@out);
    cout << "Vulkan " << (v >> 22) << "." << ((v >> 12) & 1023) << "\n";
    return 0;
}
```

Output:

```
Vulkan 1.1
```

## Reference

Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.

### `Native`

| call | gives | what it does |
|---|---|---|
| `Native::open(String lib)` | `int` | the handle of a library (`libvulkan.so` ...), 0 if it is not there or the program was not built with `-dyn` |
| `Native::sym(int handle, String name)` | `int` | the address of a function of a library, 0 if none |
| `Native::call0(int fn)` | `int` | call a C function (an address) with no argument |
| `Native::call1(int fn, int a)` | `int` | ... with 1 whole number or pointer |
| `Native::call2(int fn, int a, int b)` | `int` | ... with 2 |
| `Native::call3(int fn, int a, int b, int c)` | `int` | ... with 3 |
| `Native::call4(int fn, int a, int b, int c, int d)` | `int` | ... with 4 |
| `Native::call5(int fn, int a, int b, int c, int d, int e)` | `int` | ... with 5 |
| `Native::call6(int fn, int a, int b, int c, int d, int e, int g)` | `int` | ... with 6 |
| `Native::call7(int fn, int a, int b, int c, int d, int e, int g, int h)` | `int` | ... with 7 |
| `Native::call8(int fn, int a, int b, int c, int d, int e, int g, int h, int i)` | `int` | ... with 8 (the result is what the function returns in x0) |
| `Native::call9(int fn, int a, int b, int c, int d, int e, int g, int h, int i, int j)` | `int` | nine integer or pointer arguments (glTexImage2D, glTexSubImage2D) |
| `Native::callf1(int fn, float a)` | `void` | call with 1 float argument |
| `Native::callf2(int fn, float a, float b)` | `void` | with 2 floats |
| `Native::callf3(int fn, float a, float b, float c)` | `void` | with 3 floats |
| `Native::callf4(int fn, float a, float b, float c, float d)` | `void` | with 4 floats (glClearColor) |
| `Native::calli_f1(int fn, int a, float x)` | `void` | a whole number first, then 1 float (glUniform1f) |
| `Native::calli_f2(int fn, int a, float x, float y)` | `void` | ... then 2 floats |
| `Native::calli_f3(int fn, int a, float x, float y, float z)` | `void` | ... then 3 floats |
| `Native::calli_f4(int fn, int a, float x, float y, float z, float w)` | `void` | ... then 4 floats |
| `Native::text(int a)` | `String` | a String from the C text (ending with 0) at an address |
| `Native::peek8(int a)` | `int` | read 1 byte of memory |
| `Native::peek32(int a)` | `int` | read 32 bits |
| `Native::peek64(int a)` | `int` | read 64 bits |
| `Native::poke32(int a, int v)` | `void` | write 32 bits |
| `Native::poke64(int a, int v)` | `void` | write 64 bits |
