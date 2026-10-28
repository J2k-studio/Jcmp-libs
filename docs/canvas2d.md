# `<canvas2d>` — canvas2d

Install: `jc lib install canvas2d`   Use: `#import <canvas2d>`



## About (the header of the library)

```
canvas2d 0.1.0 -- one interface for drawing 2D, so that a game is written once and runs on every graphics backend.   #import <canvas2d>   (license: MPL-2.0)
void draw_scene(Canvas2d^ c) {
c^.begin();  c^.clear(Color::rgb(10, 20, 40));
c^.rect(10.0, 10.0, 50.0, 30.0, Color::rgb(255, 200, 60));
c^.circle(100.0, 60.0, 20.0, Color::rgba(255, 255, 255, 128));
c^.line(0.0, 0.0, 100.0, 100.0, 2.0, Color::rgb(255, 0, 0));
c^.end();                                           // the frame is drawn here
}
The backends (each one is a struct that says  impl Canvas2d ):  GlCanvas (OpenGL ES 3, <glcanvas>), AppCanvas (the commands of the Jaric app, <gpu>).
Coordinates are dots of the surface: (0, 0) is the top left, y grows downwards. Colours are 0xAARRGGBB (Color::rgb is opaque).
has_instancing() / has_shaders() tell what the backend can do, so that a game can choose a cheaper way where it cannot.
```

## Reference

Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.

### `Color`

| call | gives | what it does |
|---|---|---|
| `Color::rgb(int r, int g, int b)` | `int` |  |
| `Color::rgba(int r, int g, int b, int a)` | `int` |  |
