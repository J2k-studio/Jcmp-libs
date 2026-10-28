# `<compute>` — compute

Install: `jc lib install compute`   Use: `#import <compute>`



## About (the header of the library)

```
compute 0.1.0 -- GPU compute that is compiled once and run many times on numbers that stay on the chip.   #import <opengl3> <compute>   (needs jcmp -dyn; license: MPL-2.0)
Gl gl = Gl::open(64, 64, 3, 1);
Kernel k = Kernel::make(gl, glsl_source);           // "#version 310 es ... layout(std430, binding = 0) buffer A { float a[]; };  layout(std430, binding = 1) buffer B { float b[]; };"
if !k.ok { cout << k.error << "\n"; return; }
GpuBuffer a = GpuBuffer::make(gl, 0, data);         // binding 0; `data` is a Floats; it is sent once
k.run(gx, gy, gz);                                  // one run = gx * gy * gz groups of the size written in the shader (local_size_x ...); many runs without copying
Floats out = a.read();                              // the numbers come back only when you ask
a.write(more);                                      // send new numbers (same size) when the program changes them
A buffer keeps its number (binding) for the shader; use the bindings 0, 1, 2 ... for several buffers. Compile errors: k.error holds the log of the driver.
```

## Reference

Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.

### `GpuBuffer`

| call | gives | what it does |
|---|---|---|
| `GpuBuffer::make(Gl gl, int binding, Floats data)` | `GpuBuffer` |  |
| `x.write(Floats data)` | `void` | new numbers of the same count |
| `x.read()` | `Floats` |  |
### `Kernel`

| call | gives | what it does |
|---|---|---|
| `Kernel::make(Gl gl, String src)` | `Kernel` |  |
| `x.run(int gx, int gy, int gz)` | `void` |  |
