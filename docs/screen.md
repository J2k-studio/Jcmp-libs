# `<screen>` — a picture of colour dots in the terminal

Install: `jget -li install screen`   Use: `#import <screen>`

Two dots share one character cell (half blocks), 24-bit colour.

## About (the header of the library)

```
Screen: a picture of colour dots (rgb) shown in the terminal. Two dots sit in one character cell (the upper half
block with a colour for the top and a colour for the bottom), so a terminal of 100 x 40 characters gives 100 x 80 dots.
#import <gfx>   using gfx::screen;
Screen s = Screen::make(Term::cols(), (Term::rows() - 1) * 2);
s.clear(0, 0, 0);   s.set(10, 5, 255, 120, 40);   s.glow(0.6);   s.show();
A colour is three numbers 0..255, or one packed number from Screen::rgb(r, g, b).
```

## Example

```jk
#import <stdlib>
#import <gfx>
using gfx::screen;
void main() {
    Screen s = Screen::make(8, 4);
    s.clear(0, 0, 0);
    s.set(2, 1, 255, 120, 40);
    cout << s.w << "x" << s.h << " dots, rgb(255,120,40) = " << Screen::rgb(255, 120, 40) << "\n";
}
```

Output:

```
8x4 dots, rgb(255,120,40) = 16742440
```

## Reference

Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.

### `Screen`

| call | gives | what it does |
|---|---|---|
| `Screen::make(int w, int h)` | `Screen` | a picture of w x h dots (h even; two dots share a character) |
| `x.free()` | `void` | give the memory back |
| `Screen::rgb(int r, int g, int b)` | `int` | pack red, green, blue into one number 0xRRGGBB |
| `x.clear(int r, int g, int b)` | `void` | fill with a colour |
| `x.set(int x, int y, int r, int g, int b)` | `void` | set a dot |
| `x.set_packed(int x, int y, int c)` | `void` | set a dot with a packed colour |
| `x.add(int x, int y, int r, int g, int b)` | `void` | add a colour to a dot (light adds up) |
| `x.get(int x, int y)` | `int` | the packed colour of a dot |
| `x.blend(int x, int y, int r, int g, int b, double a)` | `void` | mix a colour into a dot with an opacity a (0.0 to 1.0) |
| `x.line(int x0, int y0, int x1, int y1, int r, int g, int b)` | `void` | a line |
| `x.rect(int x, int y, int w, int h, int r, int g, int b)` | `void` | the outline of a rectangle |
| `x.fill_rect(int x, int y, int w, int h, int r, int g, int b)` | `void` | a filled rectangle |
| `x.circle(int cx, int cy, int rad, int r, int g, int b)` | `void` | the outline of a circle |
| `x.fill_circle(int cx, int cy, int rad, int r, int g, int b)` | `void` | a filled circle |
| `x.gradient_v(int r0, int g0, int b0, int r1, int g1, int b1)` | `void` | a vertical gradient from one colour to another |
| `x.vignette(double strength)` | `void` | darken the edges |
| `x.scanlines(double strength)` | `void` | darken every second row |
| `x.brightness(double f)` | `void` | multiply all colours |
| `x.invert()` | `void` | negative colours |
| `x.lit()` | `int` | the number of dots that are not black |
| `x.glow(double strength)` | `void` | a soft glow around the light dots |
| `x.frame()` | `String` | the picture as text with the colour codes |
| `x.show()` | `void` | print the picture |
| `x.begin()` | `void` | clear the terminal and hide the cursor |
| `x.end()` | `void` | show the cursor again |
