# `<canvas>` — drawing with characters, with a depth buffer

Install: `jc lib install canvas`   Use: `#import <canvas>`

A grid of characters; the nearest thing drawn in a place wins.

## About (the header of the library)

```
Canvas: a grid of characters to draw on, with a depth buffer (the nearest thing drawn in a place wins).
#import <gfx>   using gfx::canvas;
Canvas c = Canvas::make(100, 37);
c.clear();   c.ball(p, 2.0, ".:-=+*#%@");   c.plot(q, 'E');   c.text(2, 1, "hello");   c.show();
Points are vec3: x to the right, y down, z away from the viewer; plot() looks at them in perspective.
```

## Example

```jk
#import <stdlib>
#import <gfx>
using gfx::canvas;
void main() {
    Canvas c = Canvas::make(20, 5);
    c.clear();
    c.text(2, 1, "hello");
    c.show();
}
```

Output:

```
                    
  hello
```

## Reference

Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.

### `Canvas`

| call | gives | what it does |
|---|---|---|
| `Canvas::make(int w, int h)` | `Canvas` | a canvas of w x h characters (a character is about twice as high as wide) |
| `x.free()` | `void` | give the memory of the canvas back |
| `x.clear()` | `void` | empty the canvas: spaces, and the depth buffer reset |
| `x.put(int x, int y, char c)` | `void` | put one character at (x, y) |
| `x.get(int x, int y)` | `char` | the character at (x, y) |
| `x.text(int x, int y, String s)` | `void` | write a text from (x, y) to the right |
| `x.plot(vec3 p, char c)` | `void` | draw a point p of 3D (vec3) with the character c; a nearer point wins |
| `x.line(vec3 a, vec3 b, char c)` | `void` | a line between two points of 3D |
| `x.ball(vec3 p, double r, String ramp)` | `void` | a ball: the middle p, the radius r, shaded with the characters of `ramp` from dark to light |
| `x.ball_lit(vec3 p, double r, String ramp, vec3 to_light)` | `void` | the same, lit from the direction `to_light` |
| `x.frame()` | `String` | the picture as one String (lines separated by new lines) |
| `x.clear_screen()` | `void` | clear the terminal and move the cursor home |
| `x.show()` | `void` | print the picture on the terminal |
