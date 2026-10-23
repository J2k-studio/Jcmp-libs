# `<opengl3>` — OpenGL ES 3.1 / 2.0 on the real driver

Install: `jget -li install opengl3`   Use: `#import <opengl3>`   Build the program with `jcmp -dyn`.

Off-screen drawing with shaders (GLSL), triangles, reading pixels and compute shaders on the graphics chip; build with `jcmp -dyn`.

## About (the header of the library)

```
opengl3 0.1.0 -- OpenGL ES 3.1 (and 2.0) from J2K, on the real driver of the phone: no app is needed.   #import <opengl3>
(needs  jcmp -dyn  and the library native; license: MPL-2.0)
Gl gl = Gl::open(256, 256, 3, 1);               // an off-screen context (EGL pbuffer): width, height, ES version 3.1 (or 2, 0)
gl.clear_color(0.1, 0.2, 0.4, 1.0);   gl.clear_color_buffer();
int prog = gl.program(vertex_source, fragment_source);        // 0 and gl.log when a shader does not compile
gl.use(prog);   gl.draw_triangles(vertices (a Floats), 3);
String rgba = gl.read_pixels(0, 0, 256, 256);   // 4 bytes per pixel, the first row is the bottom
gl.compute(source, 64, 1, 1);                    // OpenGL ES 3.1: a compute shader (GLSL) on the graphics chip
The functions are the ones of the OpenGL ES API in a J2K spelling (gl.gen_buffer = glGenBuffers ...); `gl.fn("glName")` gives any other
function of the library (call it with Native::call1 .. call8). The picture can be shown through the app with  gfx  (the pixels).
```

## Example

```jk
#import <stdlib>
#import <opengl3>
int main() {
    Gl gl = Gl::open(64, 64, 3, 1);
    if !gl.ok { cout << "no GL: " << gl.log << "\n"; return 1; }
    cout << "renderer " << gl.renderer << "\n";
    String vs = "#version 300 es\nlayout(location = 0) in vec2 pos;\nvoid main() { gl_Position = vec4(pos, 0.0, 1.0); }\n";
    String fs = "#version 300 es\nprecision mediump float;\nout vec4 color;\nvoid main() { color = vec4(1.0, 0.5, 0.0, 1.0); }\n";
    int prog = gl.program(vs, fs);
    if prog == 0 { cout << "shader: " << gl.log << "\n"; return 1; }
    gl.clear_color(0.0, 0.0, 0.0, 1.0);
    gl.clear_color_buffer();
    gl.use(prog);
    Floats tri = Floats::make(6);
    tri.set(0, -1.0); tri.set(1, -1.0); tri.set(2, 1.0); tri.set(3, -1.0); tri.set(4, 0.0); tri.set(5, 1.0);
    gl.draw_triangles(tri, 3);
    String px = gl.read_pixels(32, 20, 1, 1);
    cout << "triangle pixel " << (px[0] & 255) << " " << (px[1] & 255) << " " << (px[2] & 255) << " " << (px[3] & 255) << "\n";
    String out = gl.read_pixels(1, 62, 1, 1);
    cout << "corner pixel   " << (out[0] & 255) << " " << (out[1] & 255) << " " << (out[2] & 255) << "\n";
    // a compute shader: v[i] = v[i] * 2 + 1
    String cs = "#version 310 es\nlayout(local_size_x = 8) in;\nlayout(std430, binding = 0) buffer Data { float v[]; };\nvoid main() { uint i = gl_GlobalInvocationID.x; v[i] = v[i] * 2.0 + 1.0; }\n";
    Floats data = Floats::make(16);
    for i in 0..16 { data.set(i, (float)i); }
    Floats res = gl.compute(cs, data, 2, 1, 1);
    if gl.log.len > 0 { cout << "log: " << gl.log << "\n"; }
    cout << "compute: " << res.get(0) << " " << res.get(1) << " " << res.get(5) << " " << res.get(15) << "\n";
    return 0;
}
```

Output:

```
renderer Mali-G76
triangle pixel 255 128 0 255
corner pixel   0 0 0
compute: 1.000000 3.000000 11.000000 31.000000
```

## Reference

Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.

### `Floats`

| call | gives | what it does |
|---|---|---|
| `Floats::make(int count)` | `Floats` | memory for `count` numbers of 32 bits (what the chip reads) |
| `x.set(int i, float v)` | `void` | put a number |
| `x.get(int i)` | `float` | read a number |
### `Gl`

| call | gives | what it does |
|---|---|---|
| `x.fn(String name)` | `int` | the address of any OpenGL function by name (call it with Native::call1 .. call8) |
| `Gl::open(int w, int h, int major, int minor)` | `Gl` | an off-screen context: width, height, OpenGL ES version (3, 1 or 2, 0); `gl.ok`, `gl.log`, `gl.renderer` |
| `x.close()` | `void` | release the context |
| `x.viewport(int x, int y, int w, int h)` | `void` | glViewport |
| `x.clear_color(double r, double g, double b, double a)` | `void` | glClearColor (red, green, blue, alpha from 0.0 to 1.0) |
| `x.clear_color_buffer()` | `void` | paint the whole picture with the clear colour |
| `x.clear_all()` | `void` | clear colour and depth |
| `x.enable(int cap)` | `void` | glEnable |
| `x.disable(int cap)` | `void` | glDisable |
| `x.blend_alpha()` | `void` | turn on the blending of transparent colours |
| `x.finish()` | `void` | wait until the chip has finished |
| `x.error()` | `int` | glGetError (0 = no error) |
| `x.shader(int kind, String src)` | `int` | compile one shader (35633 vertex, 35632 fragment, 37305 compute); 0 and `gl.log` on a mistake |
| `x.program(String vs, String fs)` | `int` | compile a vertex and a fragment shader and link them; 0 and `gl.log` on a mistake |
| `x.use(int prog)` | `void` | make a program the one that draws |
| `x.uniform(int prog, String name)` | `int` | the place of a uniform variable of a program |
| `x.attrib(int prog, String name)` | `int` | the place of an input variable |
| `x.uniform1f(int loc, double x)` | `void` | set a float uniform |
| `x.uniform2f(int loc, double x, double y)` | `void` | set a vec2 |
| `x.uniform3f(int loc, double x, double y, double z)` | `void` | set a vec3 |
| `x.uniform4f(int loc, double x, double y, double z, double w)` | `void` | set a vec4 |
| `x.uniform1i(int loc, int v)` | `void` | set an int uniform (a texture unit) |
| `x.uniform_matrix4(int loc, Floats m)` | `void` | set a 4 x 4 matrix (16 floats) |
| `x.gen_buffer()` | `int` | a new buffer |
| `x.bind_buffer(int target, int buf)` | `void` | make a buffer the one in use (34962 array) |
| `x.buffer_data(int target, Floats data, int usage)` | `void` | send the numbers of a Floats to the buffer in use |
| `x.vertex_attrib(int index, int size, int stride_floats, int offset_floats)` | `void` | how the input variable `index` reads the buffer: size, stride and offset in floats |
| `x.draw_arrays(int mode, int first, int count)` | `void` | draw (4 = triangles) |
| `x.draw_triangles(Floats v, int count)` | `void` | send the corners (2 floats each) and draw triangles with the input 0 |
| `x.read_pixels(int x, int y, int w, int h)` | `String` | the pixels of a rectangle as bytes red, green, blue, alpha; the first row is the bottom |
| `x.compute(String src, Floats data, int gx, int gy, int gz)` | `Floats` | run a compute shader (GLSL, OpenGL ES 3.1) on the numbers of a Floats in groups gx, gy, gz; gives the changed numbers |
