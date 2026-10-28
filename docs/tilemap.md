# `<tilemap>` — tilemap

Install: `jc lib install tilemap`   Use: `#import <tilemap>`



## About (the header of the library)

```
tilemap 0.1.0 -- the world of a 2D game made of tiles (a Terraria or Stardew kind of world): layers, chunks, changes, saving.   #import <tilemap>   (needs jcmp 1.2.1.0; license: MPL-2.0)
TileMap m = TileMap::make(2000, 600, 2);   m.set(0, 10, 20, 5);   int t = m.get(0, 10, 20);       // 2000 x 600 tiles, 2 layers (0 ground, 1 things on it); a tile is a number 0..65535
if m.dirty(0, 10, 20) { ... }   m.clean();                                                        // which chunks changed since the last clean (to draw or save only those)
m.save("world.jw"); TileMap w = TileMap::load("world.jw", @ok);
The tiles are kept in chunks of 16 x 16 for each layer (a chunk that was never changed takes no room), so a big world is small in memory and a change marks one chunk.
The numbers mean what the game says; 0 is empty. Outside the world every tile is 0 and set() does nothing.
```

## Reference

Every function below is used as shown: `Type::name(...)` is a static function, `x.name(...)` a method of a value of the type.

### `TileMap`

| call | gives | what it does |
|---|---|---|
| `TileMap::make(int w, int h, int layers)` | `TileMap` |  |
| `x.inside(int layer, int x, int y)` | `bool` |  |
| `x.get(int layer, int x, int y)` | `int` |  |
| `x.set(int layer, int x, int y, int tile)` | `void` |  |
| `x.dirty(int layer, int x, int y)` | `bool` | changed since the last clean() |
| `x.clean()` | `void` |  |
| `x.used_chunks()` | `int` | how many chunks hold something (the memory is this * 256 * 8 bytes) |
| `x.fill(int layer, int x, int y, int rw, int rh, int tile)` | `void` | a rectangle of one layer |
| `x.save(String path)` | `void` | the world as text: a header, then for each chunk that exists  layer chunk  and its 256 numbers (the file of a save; small, readable) |
| `TileMap::load(String path, bool^ ok)` | `TileMap` |  |
