# `<spritebatch>` — spritebatch

Install: `jc lib install spritebatch`   Use: `#import <spritebatch>`



## About (the header of the library)

```
spritebatch 0.1.0 -- many sprites drawn in order: a texture atlas and a batch.   #import <deflate> <png> <gamej> <sprite> <spritebatch>   (needs jcmp 1.2.1.0; license: MPL-2.0)
Atlas a = Atlas::make(256, 256);                 // one big picture; small sprites are packed into it row by row
int hero = a.add(Sprites::load("hero.png", @ok)); int tree = a.add(tree_sprite);     // the number of the sprite, or -1 when the atlas is full
SpriteBatch b = SpriteBatch::make(a);
b.view(cam_x, cam_y, 320, 180);                  // optional: sprites outside this window are dropped
b.add(tree, 100, 40, 1);  b.add(hero, 50, 60, 2);  b.add_flip(hero, 80, 60, 2, true);      // sprite, x, y, layer (0..15; a higher layer is drawn later = in front)
b.flush(game);                                   // draws everything, layer by layer (the same layer in the order of add), then empties the batch
b.count (sprites waiting), b.drawn (sprites drawn by the last flush), b.flush_to(int[] dst, w, h) for any buffer, b.clear().
The atlas keeps the sprites in one Sprite (a.sheet), so a graphics chip can take it as ONE texture and the batch is one draw call.
```

## Reference

Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.

### `Atlas`

| call | gives | what it does |
|---|---|---|
| `Atlas::make(int w, int h)` | `Atlas` |  |
| `x.count()` | `int` |  |
| `x.add(Sprite s)` | `int` | packs a sprite; the number of it, or -1 when there is no room |
### `SpriteBatch`

| call | gives | what it does |
|---|---|---|
| `SpriteBatch::make(Atlas a)` | `SpriteBatch` |  |
| `x.view(int x, int y, int w, int h)` | `void` | only sprites that touch this window are kept |
| `x.add(int id, int x, int y, int layer)` | `void` |  |
| `x.add_flip(int id, int x, int y, int layer, bool flip)` | `void` |  |
| `x.clear()` | `void` |  |
| `x.order()` | `int[]` | the order of drawing: layer by layer, inside a layer as added (a counting sort) |
| `x.flush_to(int[] dst, int dw, int dh)` | `void` |  |
| `x.flush(Game g)` | `void` |  |
