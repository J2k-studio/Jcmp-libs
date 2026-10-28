# `<gpu>` — the graphics chip through the Jaric app

Install: `jget -li install gpu`   Use: `#import <gpu>`

Commands for triangles, rectangles, lines, textures and tints are sent in one batch per picture; the app draws them with OpenGL ES.

## About (the header of the library)

```
gpu 0.1.1 -- the graphics chip for J2K programs.   #import <gpu>   (needs jcmp 1.1.0.0; license: MPL-2.0)
Gpu g = Gpu::open(320, 180);                  // a picture of 320 x 180 logical pixels, scaled to the screen (in the Jaric app)
if !g.ok() { cout << "no graphics chip here\n"; return; }
g.load(1, "ship.png");                        // a picture file becomes the texture 1
while g.running() {
g.begin();                                // touches and keys, g.dt
g.clear(Gpu::rgb(10, 20, 40));
g.rect(10, 10, 50, 30, Gpu::rgb(255, 200, 60));
g.tri(100, 100, 140, 100, 120, 60, Gpu::rgb(255, 0, 0));
g.tri_colors(200, 100, Gpu::rgb(255, 0, 0), 240, 100, Gpu::rgb(0, 255, 0), 220, 60, Gpu::rgb(0, 0, 255));
g.image(1, 150, 90, 32, 32, Gpu::rgb(255, 255, 255));      // the last number tints the picture (white = as it is)
g.end();                                  // sends the picture to the chip and waits for the next one
}
g.close();
The commands are written into a file and the Jaric app draws them with OpenGL ES (the chip does the work, not the processor).
Colours are 0xAARRGGBB (Gpu::rgb is opaque, Gpu::rgba(r,g,b,a) has an alpha). Touch: g.touching() g.tapped() g.touch_x g.touch_y.
Elsewhere (a terminal) Gpu::open gives a Gpu that is not ok(): use the library gamej there. Esc and the back key end the game.
g.renderer is the name of the chip when the app told it (for example "Mali-G76").
```

## Example

```jk
#import <stdlib>
#import <gpu>
void main() {
    Gpu g = Gpu::open(320, 180);                    // in the Jaric app; elsewhere g.ok() is false
    if !g.ok() { cout << "no graphics chip through the app here\n"; return; }
    while g.running() {
        g.begin();
        g.clear(Gpu::rgb(10, 20, 40));
        g.rect(10, 10, 50, 30, Gpu::rgb(255, 200, 60));
        g.tri(100, 100, 140, 100, 120, 60, Gpu::rgb(255, 0, 0));
        g.circle(200, 90, 20, Gpu::rgba(255, 255, 255, 128));
        g.end();
    }
    g.close();
}
```

Output:

```
no graphics chip through the app here
```

## Reference

Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.

### `Gpu`

| call | gives | what it does |
|---|---|---|
| `Gpu::rgb(int r, int g, int b)` | `int` | an opaque colour 0xFFRRGGBB |
| `Gpu::rgba(int r, int g, int b, int a)` | `int` | a colour with an alpha (0 clear, 255 solid) |
| `Gpu::open(int w, int h)` | `Gpu` | open a picture of w x h logical pixels (scaled to the screen); `ok()` is false when there is no app |
| `x.ok()` | `bool` | true when the graphics chip can be used |
| `x.running()` | `bool` | true until the game is ended |
| `x.quit()` | `void` | end after this turn |
| `x.set_fps(int fps)` | `void` | turns per second |
| `x.load(int id, String file)` | `void` | a png / jpeg file becomes the texture `id` (files of the game are found through JC_ASSETS) |
| `x.clear(int argb)` | `void` | clear the picture |
| `x.tri(int x0, int y0, int x1, int y1, int x2, int y2, int argb)` | `void` | a triangle with one colour |
| `x.rect(int x, int y, int rw, int rh, int argb)` | `void` | a rectangle |
| `x.tri_colors(int x0, int y0, int c0, int x1, int y1, int c1, int x2, int y2, int c2)` | `void` | a triangle with a colour at each corner (blended) |
| `x.image(int tex, int x, int y, int iw, int ih, int tint)` | `void` | draw a texture in a rectangle; `tint` multiplies the colours (white = as it is) |
| `x.image_part(int tex, int x, int y, int iw, int ih, int u0, int v0, int u1, int v1, int tint)` | `void` | draw a part of a texture (u0 v0 u1 v1 in millionths) |
| `x.line(int x0, int y0, int x1, int y1, int width, int argb)` | `void` | a line of a width |
| `x.circle(int cx, int cy, int r, int argb)` | `void` | a circle (made of triangles) |
| `x.note_key(int k, int now)` | `void` | (internal) |
| `x.hit(int k)` | `bool` | a key pressed since the last turn |
| `x.held(int k)` | `bool` | a key pressed lately |
| `x.touching()` | `bool` | a finger is on the screen |
| `x.tapped()` | `bool` | a finger touched the screen in this turn |
| `x.begin()` | `void` | start a turn: touches, keys, `dt` |
| `x.end()` | `void` | send the commands of the turn to the chip and wait for the next turn |
| `x.close()` | `void` | close the picture |
