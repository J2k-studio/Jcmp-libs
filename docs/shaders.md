# `<shaders>` — shaders

Install: `jc lib install shaders`   Use: `#import <shaders>`



## About (the header of the library)

```
shaders 0.1.0 -- shader source from files: #include, #define from the program, and a check for a changed file (hot reload).   #import <shaders>   (needs jcmp 1.2.1.0; license: MPL-2.0)
ShaderFile fs = ShaderFile::make("shaders/water.frag");     // reads the file; every line   #include "common.glsl"   is replaced by that file (looked up beside it)
fs.define("TILE", "16");  fs.define("USE_FOG", "1");        // becomes   #define TILE 16   after the #version line (if the text has one) or at the top
int prog = gl.program(vs.text(), fs.text());                // <opengl3>; the text is plain GLSL
if fs.changed() { fs.reload(); prog = gl.program(vs.text(), fs.text()); }     // call it once a second while developing: true when a file (or an include) changed
fs.ok (false when a file could not be read), fs.error (the reason), fs.text().
An include loop (a file that includes itself) stops at depth 8 with an error. The library needs no graphics chip: it only makes text.
```

## Reference

Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.

### `ShaderFile`

| call | gives | what it does |
|---|---|---|
| `ShaderFile::make(String path)` | `ShaderFile` |  |
| `x.reload()` | `void` |  |
| `x.changed()` | `bool` | true when a file of this shader holds other text than at the last reload |
| `x.define(String name, String value)` | `void` |  |
| `x.text()` | `String` | the GLSL text with the #define lines after the #version line |
