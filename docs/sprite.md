# `<sprite>` — sprite

Install: `jget -li install sprite`   Use: `#import <sprite>`



## About (the header of the library)

```
sprite 0.1.0 -- pictures for games: a Sprite is a picture with see-through dots; draw it, a part of it (a sprite sheet), turned, scaled.
#import <deflate>  #import <png>  #import <gamej>  #import <sprite>   (needs jcmp 1.2.1.0; license: MPL-2.0)
bool ok; Sprite hero = Sprites::load("hero.png", @ok);   hero.draw(g, 10, 20);   hero.draw_part(g, 16, 0, 16, 16, 40, 40, false);   // the second tile of a sheet
Sprite tile = hero.cut(32, 0, 16, 16);   tile.draw_scaled(g, 0, 0, 3);
The dots are numbers 0xAARRGGBB (alpha 255 = solid, 0 = see-through, between = mixed with what is on the screen). The drawing is clipped to the screen.
blit* draw on any int[] of w * h dots (0xRRGGBB, like the screen of <gamej>), so that they can be used and tested without a window.
```

## Reference

Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.

### `Sprite`

| call | gives | what it does |
|---|---|---|
| `Sprite::put(int[] dst, int dw, int dh, int x, int y, int c)` | `void` | one dot of the sprite on the screen buffer: alpha 0 skips it, 255 puts it, between mixes it with what was there |
| `x.blit(int[] dst, int dw, int dh, int x, int y)` | `void` | the whole sprite at (x, y) |
| `x.blit_part(int[] dst, int dw, int dh, int sx, int sy, int sw, int sh, int x, int y, bool flip)` | `void` | the part (sx, sy, sw, sh) of the sprite at (x, y); flip turns it left to right |
| `x.blit_scaled(int[] dst, int dw, int dh, int x, int y, int scale)` | `void` | the whole sprite made bigger by a whole number (pixels stay sharp) |
| `x.draw(Game g, int x, int y)` | `void` |  |
| `x.draw_part(Game g, int sx, int sy, int sw, int sh, int x, int y, bool flip)` | `void` |  |
| `x.draw_scaled(Game g, int x, int y, int scale)` | `void` |  |
| `x.cut(int sx, int sy, int sw, int sh)` | `Sprite` | a new sprite made of a part of this one (a tile of a sheet) |
### `Sprites`

| call | gives | what it does |
|---|---|---|
| `Sprites::from_image(Image im)` | `Sprite` | the sprite of a decoded picture |
| `Sprites::load(String path, bool^ ok)` | `Sprite` | a PNG file; ok = false when it cannot be read |
