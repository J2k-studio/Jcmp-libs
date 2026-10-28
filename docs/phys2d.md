# `<phys2d>` — phys2d

Install: `jc lib install phys2d`   Use: `#import <phys2d>`



## About (the header of the library)

```
phys2d 0.1.0 -- a body that falls and walks in a world of tiles, and a camera that follows it.   #import <tilemap>  #import <phys2d>   (needs jcmp 1.2.1.0; license: MPL-2.0)
Body b = Body::make(50.0, 0.0, 8.0, 16.0);        // x, y, width, height in dots (the top left corner)
b.vx = 120.0;  b.jump(300.0);                       // speed in dots a second; jump() gives an upward speed when the body stands on something
b.step(world, 0, 16, 99, 1.0 / 60.0, 900.0);       // the tile layer 0; tiles are 16 dots; the numbers 1..99 are solid; dt in seconds; gravity in dots a second a second
b.on_ground, b.hit_x, b.hit_y tell what it touched in the last step.
Camera c = Camera::make(320, 180);   c.follow(b.x, b.y, 0.15);   c.limit(2000 * 16, 600 * 16);   int sx = c.screen_x(wx); int sy = c.screen_y(wy);
The body is moved one axis at a time and put against the tile it meets (no passing through at speeds below one tile in a step).
```

## Reference

Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.

### `Body`

| call | gives | what it does |
|---|---|---|
| `Body::make(double x, double y, double w, double h)` | `Body` |  |
| `Body::blocked(TileMap m, int layer, int ts, int solid_max, double bx, double by, double bw, double bh)` | `bool` | is there a solid tile in the world where the box (bx, by, bw, bh) is |
| `x.jump(double speed)` | `void` |  |
| `x.step(TileMap m, int layer, int ts, int solid_max, double dt, double gravity)` | `void` |  |
### `Camera`

| call | gives | what it does |
|---|---|---|
| `Camera::make(int vw, int vh)` | `Camera` |  |
| `x.limit(int world_w, int world_h)` | `void` | the world is this big: the camera does not show beyond it |
| `x.follow(double tx, double ty, double smooth)` | `void` | goes toward the point that is in the middle of the view: smooth = the part of the way in one call (1.0 at once, 0.1 slowly) |
| `x.screen_x(double wx)` | `int` |  |
| `x.screen_y(double wy)` | `int` |  |
| `x.world_x(int sx)` | `double` |  |
| `x.world_y(int sy)` | `double` |  |
