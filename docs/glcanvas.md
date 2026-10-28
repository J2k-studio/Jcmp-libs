# `<glcanvas>` — glcanvas

Install: `jc lib install glcanvas`   Use: `#import <glcanvas>`



## About (the header of the library)

```
glcanvas 0.1.0 -- the Canvas2d interface on OpenGL ES 3: every shape of a frame goes into one buffer and is drawn with ONE call.   #import <opengl3> <canvas2d> <glcanvas>   (license: MPL-2.0)
Gl gl = Gl::open(320, 180, 3, 1);                      // off-screen; in an app: Gl::attach(w, h)
GlCanvas c; c.init(); c.setup(gl, 320.0, 180.0);       // sets the shader, the buffer and the size of the surface in dots
Canvas2d^ cv = @c;   cv^.begin(); cv^.rect(...); cv^.end();       // c.draws counts the draw calls of the last frame (1 for a whole frame)
The batch holds 8192 triangles; when it is full it is drawn and started again (one more call).
```

## Reference

Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.

### `GlCanvas`

| call | gives | what it does |
|---|---|---|
| `x.init()` | `void` |  |
| `x.setup(Gl gl, double w, double h)` | `void` |  |
| `x.vertex(double x, double y, int argb)` | `void` | one vertex: x, y, r, g, b, a (the colour as numbers from 0 to 1) |
| `x.flush()` | `void` | send the batch to the chip and draw it |
| `x.begin()` | `void` |  |
| `x.clear(int argb)` | `void` |  |
| `x.rect(double x, double y, double w, double h, int argb)` | `void` |  |
| `x.tri(double x0, double y0, double x1, double y1, double x2, double y2, int argb)` | `void` |  |
| `x.line(double x0, double y0, double x1, double y1, double width, int argb)` | `void` | a line of the given width: a thin rectangle along the line |
| `x.circle(double cx, double cy, double r, int argb)` | `void` | a fan of 32 triangles |
| `x.end()` | `void` |  |
| `x.has_instancing()` | `bool` |  |
| `x.has_shaders()` | `bool` |  |
