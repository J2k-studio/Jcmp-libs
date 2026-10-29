# `<glcanvas>` — glcanvas

Install: `jc lib install glcanvas`   Use: `#import <glcanvas>`



## About (the header of the library)

```
glcanvas 0.2.1 -- the Canvas2d interface on OpenGL ES 3 (and on ES 2): every shape of a frame goes into one buffer and is drawn with ONE call.   #import <opengl3> <canvas2d> <glcanvas>   (license: MPL-2.0)
0.2.1: image_rot (a picture turned about its middle; a method of GlCanvas, not of the interface).
0.2.0: pictures (load a PNG, image()), the same code on an OpenGL ES 2 context (Gl::open(w, h, 2, 0)): no vertex arrays, shaders of GLSL 100.
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
| `x.attribs()` | `void` | the two attributes of the shape shader: pos (2 floats) and col (4 floats) in the bound buffer |
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
| `x.load(String path)` | `int` | a PNG file becomes a picture number (-1 when the file cannot be read) |
| `x.image(int pic, double x, double y, double w, double h, int tint)` | `void` | the picture in the box (x, y, w, h); drawn at once (the shapes before it are drawn first, so the order is kept) |
| `x.image_rot(int pic, double cx, double cy, double w, double h, double angle, int tint)` | `void` | the picture in a box of w x h dots whose middle is (cx, cy), turned by `angle` radians (clockwise on the screen, about the middle) |
